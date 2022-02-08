extends CanvasLayer

func _ready():
	$PanelContainer/VBoxContainer/Button.connect("pressed", self, "on_next_button_pressed")
	score()

func on_next_button_pressed():
	$"/root/LevelManager".increment_level()

func score():
	var coin_label = $"../LevelUI/MarginContainer/HBoxContainer/CoinLabel"
	var timer_label = $"../LevelUI/MarginContainer/HBoxContainer2/TimerLabel"
	var score = 0
	var coins = coin_label.text.rsplit('/')
	var coin = int(coins[0])
	
	if (coin == 0):
		coin = 1
	
	if (float(timer_label.text) < 5):
		score = coin * (5 - float(timer_label.text))
	
	$PanelContainer/VBoxContainer/Score.text = "Score: " + str(int(score))
