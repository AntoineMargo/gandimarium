extends Node

#const TILE_SIZE = 40
const TILE_SIZE = 16

var ui_manager = UIManager.new()
var dialog_manager = DialogManager.new()
var world_manager = WorldManager.new()
var crisis_manager = CrisisManager.new()
var input_manager = InputManager.new()
var cursor_manager = CursorManager.new()

var game_root = null

@onready var menu_scene = preload("res://interface/pause_menu.tscn")
@onready var inventory_window := preload("res://interface/inventory.tscn").instantiate()

var ui_log: TextEdit = null
var menu_instance: Node = null
var items_list: VBoxContainer = null

var current_camera: Camera2D = null

var pause_menu_active: bool = false
#var activity_mode: bool = false
#var activity_mode = null

var focus_char: Creature
var selected_char: Creature

func _process(_delta: float) -> void:
	input_manager.BasicControls()
	ui_manager.drag_fail_restore()

#func _input(event: InputEvent) -> void:
	#pass

#func _unhandled_input(event: InputEvent) -> void:
	#pass

func toggle_pause():
	if pause_menu_active:
		unpause_game()
	else:
		menu_instance = menu_scene.instantiate()
		get_tree().current_scene.add_child(menu_instance)
		get_tree().paused = true
		pause_menu_active = true

func unpause_game():
	if menu_instance:
		menu_instance.queue_free()
		menu_instance = null
	get_tree().paused = false
	pause_menu_active = false

func _ready() -> void:
	randomize()
	add_child(crisis_manager)
	add_child(ui_manager)
	add_child(dialog_manager)
	add_child(inventory_window)
	add_child(input_manager)
	add_child(world_manager)
	add_child(cursor_manager)
	inventory_window.visible = false
	items_list = inventory_window.get_node("Inventory/MainVBox/SeparHBox/Scroller/ItemsList")
	await get_tree().create_timer(0.1).timeout
	SignalBus.change_cursor.emit("default")
