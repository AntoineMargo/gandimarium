extends Node
class_name GameSession

@onready var world_container = $WorldContainer
@onready var camera = $Camera2D

#const TILE_SIZE = 40
#const TILE_SIZE = 16

var state_manager = StateManager.new()
var ui_manager = UIManager.new()
var dialog_manager = DialogManager.new()
var overworld_manager = OverworldManager.new()
var world_manager = WorldManager.new()
var crisis_manager = CrisisManager.new()
var input_manager = InputManager.new()
var cursor_manager = CursorManager.new()
var ai_manager = AIManager.new()
var time_manager = TimeManager.new()
var noise_manager = NoiseManager.new()
var door_manager = DoorManager.new()
var reaction_manager = ReactionManager.new()
var map_manager = MapManager.new()


@onready var pause_menu = preload("res://interface/pause_menu.tscn")
@onready var container_window = preload("res://interface/container_window/container_window.tscn").instantiate()
@onready var all_info_window = preload("res://interface/all_char_info_window/all_char_info_window.tscn").instantiate()

@onready var world_info = preload("res://interface/screen/world_info.tscn").instantiate()
@onready var condition_viewer = preload("res://interface/screen/condition_viewer.tscn").instantiate()

var active_window: Node = all_info_window
var ui_log: RichTextLabel = null
var menu_instance: Node = null
var items_list: VBoxContainer = null
var container_list: VBoxContainer = null

var pause_menu_active: bool = false

var simulation_lock: bool = false
var player_lock: bool = false
var active_party: PartyData

var activity_handler: Activity = null
var last_hovered_tile: Vector3i
var pending_crisis_operation_count: int = 0


func _unhandled_input(event: InputEvent) -> void:
	if world_manager.current_map:
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
	if world_manager.current_map:
		input_manager.BasicControls()
		ui_manager.drag_fail_restore()


func begin_async_operation() -> void:
	pending_crisis_operation_count += 1


func end_async_operation() -> void:
	pending_crisis_operation_count -= 1
	if pending_crisis_operation_count == 0:
		SignalBus.operation_finished.emit()
	
	
#func no_pending_async_operation() -> bool:
	#if pending_crisis_operation_count == 0:
		#return true
	#else:
		#return false


func handle_world_hover(tile: Vector3i) -> void:
	if Input.is_action_pressed("Ctrl") and Global.selected_char and not activity_handler:
		var selected_weapon_activity: Activity = Global.selected_char.get_selected_weapon_activity()
		selected_weapon_activity.execute()
	
	if tile == last_hovered_tile:
		return

	last_hovered_tile = tile

	if activity_handler:
		if activity_handler.has_method("handle_hover"):
			activity_handler.handle_hover(tile)
			return


	world_manager.hover_tile.set_tile(tile)


func toggle_pause():
	if pause_menu_active:
		unpause_game()
	else:
		menu_instance = pause_menu.instantiate()
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
	for creature in world_manager.current_map.creatures:
		if creature.data.player_controlled:
			new_party.members_by_uid.append(creature.data.uid)


func wait_frame(amount: int = 1):
	for i in range(amount):
		await get_tree().process_frame


func set_active_window(window: Node) -> void:
	if active_window == window:
		return
	all_info_window.layer = 100
	container_window.layer = 100

	active_window = window
	active_window.layer = 150


#func clear_data() -> void:
	#for child in world_container.get_children():
		#child.free()
	#world_manager.clear_data()
	#crisis_manager.clear_data()
	#door_manager.clear_data()
	#ai_manager.clear_data()
	#time_manager.clear_data()
	#selected_char = null
	#focus_char = null


func setup() -> void:
	add_child(all_info_window)
	add_child(container_window)
	add_child(world_info)
	add_child(condition_viewer)
	
	all_info_window.visible = false
	container_window.visible = false
	world_info.visible = true
	items_list = all_info_window.get_node("%ItemsList")
	container_list = container_window.get_node("Control/ColorRect/VBoxContainer/ScrollContainer/ItemList")
	await get_tree().create_timer(0.1).timeout
	SignalBus.change_cursor.emit("default")

	if not is_instance_valid(world_manager.selection_highlight):
		world_manager.selection_highlight = preload("res://interface/local_map/selection_highlight/selection_highlight.tscn").instantiate()
	var time = time_manager
	$CanvasModulate.update_light(time.days, time.hours, time.minutes, time.seconds)
	world_info.change_time(time.days, time.hours, time.minutes, time.seconds)


func load_test_map() -> void:
	map_manager.load_map("region3")


func setup_global() -> void:
	Global.game_session = self
	Global.state_manager = state_manager
	Global.ui_manager = ui_manager
	Global.dialog_manager = dialog_manager
	Global.overworld_manager = overworld_manager
	Global.world_manager = world_manager
	Global.crisis_manager = crisis_manager
	Global.input_manager = input_manager
	Global.cursor_manager = cursor_manager
	Global.ai_manager = ai_manager
	Global.time_manager = time_manager
	Global.noise_manager = noise_manager
	Global.door_manager = door_manager
	Global.reaction_manager = reaction_manager
	Global.map_manager = map_manager


func _ready() -> void:
	randomize()
	
	setup_global()
	
	add_child(state_manager)
	add_child(crisis_manager)
	add_child(ui_manager)
	add_child(dialog_manager)
	add_child(input_manager)
	add_child(overworld_manager)
	add_child(world_manager)
	add_child(cursor_manager)
	add_child(ai_manager)
	add_child(time_manager)
	add_child(noise_manager)
	add_child(door_manager)
	add_child(reaction_manager)
	add_child(map_manager)

	call_deferred("setup")
	call_deferred("load_test_map")

	camera.position = Vector2(0, 300)





#func _ready():
	#Global.game_root = self
	#load_map("res://locations/test_location_2/region.scn")
	##load_map("res://locations/test_location_3/region.scn")
	#Global.camera = $Camera2D
	#if not is_instance_valid(Global.world_manager.selection_highlight):
		#Global.world_manager.selection_highlight = preload("res://interface/local_map/selection_highlight/selection_highlight.tscn").instantiate()
	#self.add_child(Global.world_manager.selection_highlight)
	#var time = Global.time_manager
	#$CanvasModulate.update_light(time.days, time.hours, time.minutes, time.seconds)
	#Global.world_info.change_time(time.days, time.hours, time.minutes, time.seconds)
	#Global.world_info.visible = true

#func load_map(path: String):
	#Global.clear_data()
	#var world_container = $WorldContainer
#
	#for child in world_container.get_children():
		#child.free()
#
	#var new_map_scene = load(path)
	#var new_map = new_map_scene.instantiate()
	#world_container.add_child(new_map)
	#
	#$Camera2D.position = Vector2(0, 300)
#
	#Global.world_manager.current_map = new_map
	#await get_tree().process_frame
	#Global.world_manager.selection_highlight.update_selection_highlight()
