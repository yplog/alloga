extends CanvasLayer

func _ready():
	$PanelContainer/VBoxContainer/Button.connect("pressed", self, "on_next_button_pressed")

func on_next_button_pressed():
	$"/root/LevelManager".increment_level()
