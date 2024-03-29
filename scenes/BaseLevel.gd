extends Node

export(PackedScene) var levelCompleteScene

signal coin_total_changed
signal reset_timer
signal stop_timer

onready var timer = get_node("Timer")

var playerScene = preload("res://scenes/Player.tscn")
var spawnPosition = Vector2.ZERO
var currentPlayerNode = null
var totalCoins = 0
var collectedCoins = 0

func _ready():
	spawnPosition = $Player.global_position
	register_player($Player)
	coin_total_changed(get_tree().get_nodes_in_group("coin").size())
	
	$Flag.connect("player_won", self, "on_player_won")

func coin_collected():
	collectedCoins += 1
	print("Coins: ", totalCoins, " ", collectedCoins)
	emit_signal("coin_total_changed", totalCoins, collectedCoins)

func coin_total_changed(newTotal):
	totalCoins = newTotal
	emit_signal("coin_total_changed", totalCoins, collectedCoins)

func register_player(player):
	currentPlayerNode = player
	currentPlayerNode.connect("died", self, "on_player_died", [], CONNECT_DEFERRED)

func create_player():
	var playerInstance = playerScene.instance()
	add_child_below_node(currentPlayerNode, playerInstance)
	playerInstance.global_position = spawnPosition
	register_player(playerInstance)

func reset_timer():
	emit_signal("reset_timer")

func stop_timer():
	emit_signal("stop_timer")

func on_player_died():
	currentPlayerNode.queue_free()
	create_player()

func on_player_won():
	timer.stop()
	stop_timer()
	currentPlayerNode.queue_free()
	var levelComplete = levelCompleteScene.instance()
	add_child(levelComplete)
	#$"/root/LevelManager".increment_level()
