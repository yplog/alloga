extends Position2D

export(PackedScene) var enemyScene

var currentEnemyNode = null
var spawnOnNextTick = false

func _ready():
	$SpawnTimer.connect("timeout", self, "on_spawn_timer_timeout")
	call_deferred("spawn_enemy")

func spawn_enemy():
	currentEnemyNode = enemyScene.instance()
	get_parent().add_child(currentEnemyNode)
	currentEnemyNode.global_position = global_position

func check_enemy_spawn():
	if (!is_instance_valid(currentEnemyNode)):
		if (spawnOnNextTick):
			spawn_enemy()
		else:
			spawnOnNextTick = true

func on_spawn_timer_timeout():
	check_enemy_spawn()
