extends Control

@onready var start_button = $ColorRect/CenterContainer/VBoxContainer/StartButton
@onready var exit_button = $ColorRect/CenterContainer/VBoxContainer/ExitButton

func _ready():
	start_button.pressed.connect(_on_StartButton_pressed)
	exit_button.pressed.connect(_on_ExitButton_pressed)
	print("main menu script loaded")

func _on_StartButton_pressed():
	print("Start button pressed")
	#get_tree().change_scene_to_file("res://locations/world/world.tscn")
	get_tree().change_scene_to_file("res://locations/game_root.tscn")

func _on_ExitButton_pressed():
	print("exit button pressed")
	get_tree().quit()

#@export var menu_scene: PackedScene = preload("res://scenes/main_menu.tscn")
#var menu_instance: Node = null
#
#func toggle_menu(parent_node: Node):
	#if menu_instance:
		#menu_instance.queue_free()
		#menu_instance = null
	#else:
		#menu_instance = menu_scene.instantiate()
		#parent_node.add_child(menu_instance)
		#menu_instance.set_anchors_and_margins_preset(Control.PRESET_FULL_RECT)
#
