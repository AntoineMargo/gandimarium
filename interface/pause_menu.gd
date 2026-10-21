extends Control

@onready var exit_button = $ColorRect/CenterContainer/VBoxContainer/ExitButton
@onready var save_button = $ColorRect/CenterContainer/VBoxContainer/SaveButton
@onready var restart_button = $ColorRect/CenterContainer/VBoxContainer/RestartButton
@onready var resume_button = $ColorRect/CenterContainer/VBoxContainer/ResumeButton


func _on_save_button_pressed() -> void:
	if Global.state_manager.save_game_state():
		SignalBus.message.emit("Game saved.")
	Global.game_session.unpause_game()


func _on_restart_button_pressed() -> void:
	print("Restart button pressed")
	Global.game_session.unpause_game()
	Global.game_root.start_session()


func _on_exit_button_pressed() -> void:
	print("exit button pressed")
	get_tree().quit()


func _on_resume_button_pressed():
	Global.game_session.unpause_game()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("F12"):
		Global.game_session.unpause_game()


func _ready():
	exit_button.pressed.connect(_on_exit_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)
	resume_button.pressed.connect(_on_resume_button_pressed)
	save_button.pressed.connect(_on_save_button_pressed)
	print("main menu script loaded")
