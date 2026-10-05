extends Control

@onready var exit_button = $ColorRect/CenterContainer/VBoxContainer/ExitButton
@onready var restart_button = $ColorRect/CenterContainer/VBoxContainer/RestartButton
@onready var resume_button = $ColorRect/CenterContainer/VBoxContainer/ResumeButton


func _on_restart_button_pressed() -> void:
	print("Restart button pressed")
	Global.unpause_game()
	#Global.game_root.load_map("res://locations/test_location_2/region.scn")
	#Global.game_root.load_map("res://locations/test_location_3/region.scn")
	Global.game_root.start_session()


func _on_exit_button_pressed() -> void:
	print("exit button pressed")
	get_tree().quit()


func _on_resume_button_pressed():
	Global.unpause_game()


func _ready():
	exit_button.pressed.connect(_on_exit_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)
	resume_button.pressed.connect(_on_resume_button_pressed)
	print("main menu script loaded")
