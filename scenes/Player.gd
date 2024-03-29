extends KinematicBody2D

signal died

enum State { NORMAL, DASHING }

export(int, LAYERS_2D_PHYSICS) var dashHazardMask

var footstepParticles = preload("res://scenes/FootstepParticles.tscn")

const GRAVITY = 1000
var maxHorizontalSpeed = 140
var jumpSpeed = 500
var jumpTerminationMultiplier = 3
var velocity = Vector2.ZERO
var horizontalAcceleration = 8000
var hasDoubleJump = false
var hasDash = false
var maxDashSpeed = 500
var minDashSpeed = 200

var currentState = State.NORMAL
var isStateNew = true

var defaultHazardMask = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$HazardArea.connect("area_entered", self, "on_hazard_area_entered")
	$AnimatedSprite.connect("frame_changed", self, "on_animated_sprite_frame_changed")
	defaultHazardMask = $HazardArea.collision_mask


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match currentState:
		State.NORMAL:
			process_normal(delta)
		State.DASHING:
			process_dash(delta)
	
	isStateNew = false


func change_state(newState):
	currentState = newState
	isStateNew = true


func process_normal(delta):
	if (isStateNew):
		$DashParticles.emitting = false
		$DashArea/CollisionShape2D.disabled = true
		$HazardArea.collision_mask = defaultHazardMask

	var moveVector = get_movement_vector()
	
	velocity.x = moveVector.x * horizontalAcceleration * delta
	if (moveVector.x == 0):
		velocity.x = lerp(0, velocity.x, pow(2, -50 * delta))
	
	velocity.x = clamp(velocity.x, -maxHorizontalSpeed, maxHorizontalSpeed)
	
	if (moveVector.y < 0 && (is_on_floor() || !$CoyoteTimer.is_stopped() || hasDoubleJump)):
		velocity.y = moveVector.y * jumpSpeed
		
		if (!is_on_floor() && $CoyoteTimer.is_stopped()):
			hasDoubleJump = false
		
		$CoyoteTimer.stop()
	
	if (velocity.y < 0 && !Input.is_action_just_pressed("jump")):
		velocity.y += GRAVITY * jumpTerminationMultiplier * delta
	else:
		velocity.y += GRAVITY * delta
	
	var wasOnFloor = is_on_floor()
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if (wasOnFloor && !is_on_floor()):
		$CoyoteTimer.start()
	
	if (!wasOnFloor && is_on_floor() && !isStateNew):
		spawn_footstep()
	
	if (is_on_floor()):
		hasDoubleJump = true
		hasDash = true
	
	if (hasDash && Input.is_action_just_pressed("dash")):
		change_state(State.DASHING)
		call_deferred("change_state", State.DASHING)
		hasDash = false
	
	update_animation()


func process_dash(delta):
	if (isStateNew):
		$DashParticles.emitting = true
		$DashArea/CollisionShape2D.disabled = false
		$AnimatedSprite.play("jump")
		$HazardArea.collision_mask = dashHazardMask
		var moveVector = get_movement_vector()
		var velocityMod = 1
		if (moveVector.x != 0):
			velocityMod = sign(moveVector.x)
		else:
			velocityMod = 1 if $AnimatedSprite.flip_h else -1
		
		velocity = Vector2(maxDashSpeed * velocityMod, 0)
	
	velocity = move_and_slide(velocity, Vector2.UP)
	velocity.x = lerp(0, velocity.x, pow(2, -5 * delta))
	
	if (abs(velocity.x) < minDashSpeed):
		call_deferred("change_state", State.NORMAL)


func get_movement_vector():
	var moveVector = Vector2.ZERO
	moveVector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	moveVector.y = -1 if Input.is_action_just_pressed("jump") else 0
	
	return moveVector


func update_animation():
	var moveVector = get_movement_vector()
	
	if (!is_on_floor()):
		$AnimatedSprite.play("jump")
	elif (moveVector.x != 0):
		$AnimatedSprite.play("run")
	else:
		$AnimatedSprite.play("idle")
		
	if (moveVector.x != 0):
		$AnimatedSprite.flip_h = true if moveVector.x > 0 else false


func on_hazard_area_entered(_area2d):
	
	emit_signal("died")
	print("die")

func spawn_footstep():
	var footstep = footstepParticles.instance()
	get_parent().add_child(footstep)
	footstep.global_position = global_position

func on_animated_sprite_frame_changed():
	if ($AnimatedSprite.animation == "run" && $AnimatedSprite.frame == 0):
		spawn_footstep()
