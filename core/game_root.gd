extends Node
class_name GameRoot

var main_menu: MainMenu = null
var game_session: GameSession = null

func load_scene(path: String) -> Node:
	var scene = load(path)
	var instance = scene.instantiate()
	return instance


func show_main_menu() -> void:
	var scene = load_scene("res://interface/main_menu.tscn")
	main_menu = scene
	add_child(scene)
	#get_tree().change_scene_to_file("res://interface/main_menu.tscn")


func start_session() -> void:
	if main_menu:
		main_menu.queue_free()
		main_menu = null
	var scene = load_scene("res://core/game_session.tscn")
	game_session = scene
	add_child(scene)
	#Global.world_manager.load_map("region3")


func _ready() -> void:
	call_deferred("show_main_menu")
	Global.game_root = self
	print("game_root: hello")
