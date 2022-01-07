extends Node2D

func _ready():
	$Area2D.connect("area_entered", self, "on_area_entered")
	
func on_area_entered(area2d):
	$AnimationPlayer.play("pickup")
	call_deferred("disable_pickup")

func disable_picup():
	$Area2D/CollisionShape2D.disabled = true
