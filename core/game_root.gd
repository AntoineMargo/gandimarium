extends Node
class_name GameRoot

var main_menu: MainMenu = null
var game_session: GameSession = null
var character_creation: CharacterCreation = null

func load_scene(path: String) -> Node:
	var scene = load(path)
	var instance = scene.instantiate()
	return instance


func show_main_menu() -> void:
	var scene = load_scene("res://interface/main_menu.tscn")
	main_menu = scene
	add_child(scene)


func enter_character_creation() -> void:
	var scene = load_scene("res://interface/character_creation/character_creation.tscn")
	character_creation = scene
	add_child(scene)



func start_session() -> void:
	if main_menu:
		var old_menu = main_menu
		main_menu = null
		old_menu.queue_free()
		if old_menu.is_inside_tree():
			await old_menu.tree_exited

	if character_creation:
		var old_character_creation = character_creation
		character_creation = null
		old_character_creation.queue_free()
		if old_character_creation.is_inside_tree():
			await old_character_creation.tree_exited

	if game_session:
		var old_session = game_session
		game_session = null
		old_session.queue_free()
		if old_session.is_inside_tree():
			await old_session.tree_exited

	var scene = load_scene("res://core/game_session.tscn")
	game_session = scene
	add_child(scene)


func _ready() -> void:
	call_deferred("show_main_menu")
	Global.game_root = self
