extends CanvasLayer

var timer_text = "00:000"
var time = 0
var timer_on = false

func _ready():
	var baseLevels = get_tree().get_nodes_in_group("base_level")
	
	if (baseLevels.size() > 0):
		baseLevels[0].connect("coin_total_changed", self, "on_coin_total_changed")
		baseLevels[0].connect('reset_timer', self, "on_reset_timer");
		baseLevels[0].connect('stop_timer', self, "on_stop_timer");

func _process(delta):
	if (timer_on):
		time += delta
		var mils = fmod(time, 1.0) * 1000
		var secs = fmod(time, 60.0)
		var time_passed = "%02d:%03d" % [secs, mils]
		timer_text = time_passed
	
	$MarginContainer/HBoxContainer2/TimerLabel.text = str(timer_text)

func on_coin_total_changed(totalCoins, collectedCoins):
	$MarginContainer/HBoxContainer/CoinLabel.text = str(collectedCoins, "/", totalCoins)

func _on_Timer_timeout():
	timer_on = true

func on_stop_timer():
	timer_on = false

func on_reset_timer():
	time = 0
