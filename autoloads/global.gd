extends Node

#const TILE_SIZE = 40
const TILE_SIZE = 16

var ui_manager = UIManager.new()
var dialog_manager = DialogManager.new()
var overworld_manager = OverworldManager.new()
var world_manager = WorldManager.new()
var crisis_manager = CrisisManager.new()
var input_manager = InputManager.new()
var cursor_manager = CursorManager.new()
var uid_manager = UIDManager.new()
var ai_manager = AIManager.new()
var time_manager = TimeManager.new()
var noise_manager = NoiseManager.new()
var door_manager = DoorManager.new()

var game_root = null

@onready var menu_scene = preload("res://interface/pause_menu.tscn")
@onready var inventory_window = preload("res://interface/inventory_window/inventory.tscn").instantiate()
@onready var character_window = preload("res://interface/character_window/character_info.tscn").instantiate()
@onready var container_window = preload("res://interface/container_window/container_window.tscn").instantiate()

@onready var world_info = preload("res://interface/screen/world_info.tscn").instantiate()

var ui_log: RichTextLabel = null
var menu_instance: Node = null
var items_list: VBoxContainer = null
var container_list: VBoxContainer = null

var camera: Camera2D = null

var pause_menu_active: bool = false

var focus_char: Creature
var selected_char: Creature
var active_party: PartyData

var activity_handler: Activity = null
var last_hovered_tile: Vector3i

func _unhandled_input(event: InputEvent) -> void:
	if Global.world_manager.current_world:
		if activity_handler:
			activity_handler.handle_input(event)
		else:
			if event is InputEventMouseButton and event.pressed:
				match event.button_index:
					MOUSE_BUTTON_LEFT:
						if event.ctrl_pressed:
							SignalBus.simple_interact.emit(true)
						else:
							SignalBus.simple_interact.emit(false)
					MOUSE_BUTTON_RIGHT:
						SignalBus.complex_interact.emit()

func _process(_delta: float) -> void:
	if Global.world_manager.current_world:
		input_manager.BasicControls()
		ui_manager.drag_fail_restore()

#func _input(event: InputEvent) -> void:
	#pass

func handle_world_hover(tile: Vector3i) -> void:
	if tile == last_hovered_tile:
		return

	last_hovered_tile = tile

	if activity_handler:
		if activity_handler.has_method("handle_hover"):
			activity_handler.handle_hover(tile)
			return

	world_manager.hover_tile.set_tile(tile)

func save_current_map_delta():
	var delta: MapDelta = world_manager.get_map_delta(world_manager.current_world.id)

	var map_id = world_manager.current_world.id
	
	var dir_path = "res://saved/map_deltas" if OS.is_debug_build() else "user://map_deltas"
	var path = "%s/%s.tres" % [dir_path, map_id]

	var dir = DirAccess.open("res://saved/")
	if not dir.dir_exists("map_deltas"):
		dir.make_dir("map_deltas")

	var err = ResourceSaver.save(delta, path)

	if err != OK:
		push_error("Failed to save delta: %s" % err)
	else:
		print("SAVED!")

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

func create_player_party():
	var new_party = PartyData.new()
	for creature in world_manager.current_world.creatures:
		if creature.data.player_controlled:
			new_party.members_by_uid.append(creature.data.id)

func wait_frame(amount: int = 1):
	for i in range(amount):
		await get_tree().process_frame

func _ready() -> void:
	randomize()
	add_child(crisis_manager)
	add_child(ui_manager)
	add_child(dialog_manager)
	add_child(input_manager)
	add_child(overworld_manager)
	add_child(world_manager)
	add_child(cursor_manager)
	add_child(uid_manager)
	add_child(ai_manager)
	add_child(time_manager)
	add_child(noise_manager)
	add_child(door_manager)
	
	add_child(character_window)
	add_child(inventory_window)
	add_child(container_window)
	add_child(world_info)
	
	inventory_window.visible = false
	container_window.visible = false
	character_window.visible = false
	world_info.visible = false
	items_list = inventory_window.get_node("Inventory/MainVBox/SeparHBox/Scroller/ItemsList")
	container_list = container_window.get_node("Control/ColorRect/VBoxContainer/ScrollContainer/ItemList")
	await get_tree().create_timer(0.1).timeout
	SignalBus.change_cursor.emit("default")
	#active_party = create_player_party()
