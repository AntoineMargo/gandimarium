extends Control

@onready var start_button = $ColorRect/CenterContainer/VBoxContainer/StartButton
@onready var new_char_button = $ColorRect/CenterContainer/VBoxContainer/NewCharButton
@onready var exit_button = $ColorRect/CenterContainer/VBoxContainer/ExitButton

func _on_StartButton_pressed():
	print("Start button pressed")
	get_tree().change_scene_to_file("res://locations/game_root.tscn")

func _on_NewCharButon_pressed():
	print("exit button pressed")
	get_tree().change_scene_to_file("res://interface/character_creation/character_creation.tscn")

func _on_ExitButton_pressed():
	print("exit button pressed")
	get_tree().quit()

func _ready():
	start_button.pressed.connect(_on_StartButton_pressed)
	new_char_button.pressed.connect(_on_NewCharButon_pressed)
	exit_button.pressed.connect(_on_ExitButton_pressed)
	print("main menu script loaded")
