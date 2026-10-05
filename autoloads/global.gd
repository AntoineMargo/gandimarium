extends Node

const TILE_SIZE = 16

var game_root: Node = null

var game_session: Node = null

var state_manager: Node = null
var ui_manager: Node = null
var dialog_manager: Node = null
var overworld_manager: Node = null
var world_manager: Node = null
var crisis_manager: Node = null
var input_manager: Node = null
var cursor_manager: Node = null
var ai_manager: Node = null
var time_manager: Node = null
var noise_manager: Node = null
var door_manager: Node = null
var reaction_manager: Node = null
var map_manager: Node = null

var selected_char: Node = null
var focus_char: Node = null



#const TILE_SIZE = 40
#const TILE_SIZE = 16


#@onready var game_session: Node = $"."
#
#@onready var state_manager: Node = $"../state_manager"
#@onready var ui_manager: Node = $"../ui_manager"
#@onready var dialog_manager: Node = $"../dialog_manager"
#@onready var overworld_manager: Node = $"../overworld_manager"
#@onready var world_manager: Node = $"../world_manager"
#@onready var crisis_manager: Node = $"../crisis_manager"
#@onready var input_manager: Node = $"../input_manager"
#@onready var cursor_manager: Node = $"../cursor_manager"
#@onready var ai_manager: Node = $"../ai_manager"
#@onready var time_manager: Node = $"../time_manager"
#@onready var noise_manager: Node = $"../noise_manager"
#@onready var door_manager: Node = $"../door_manager"
#@onready var reaction_manager: Node = $"../reaction_manager"
#@onready var map_manager: Node = $"../map_manager"


#@onready var menu_scene = preload("res://interface/pause_menu.tscn")
#@onready var container_window = preload("res://interface/container_window/container_window.tscn").instantiate()
#@onready var all_info_window = preload("res://interface/all_char_info_window/all_char_info_window.tscn").instantiate()
#
#@onready var world_info = preload("res://interface/screen/world_info.tscn").instantiate()
#@onready var condition_viewer = preload("res://interface/screen/condition_viewer.tscn").instantiate()
#
#var active_window: Node = all_info_window
#var ui_log: RichTextLabel = null
#var menu_instance: Node = null
#var items_list: VBoxContainer = null
#var container_list: VBoxContainer = null
#
#var camera: Camera2D = null
#
#var pause_menu_active: bool = false
#
#var simulation_lock: bool = false
#var player_lock: bool = false
#var focus_char: Creature
#var selected_char: Creature
#var active_party: PartyData
#
#var activity_handler: Activity = null
#var last_hovered_tile: Vector3i
#var pending_crisis_operation_count: int = 0
#
#
#func _unhandled_input(event: InputEvent) -> void:
	#if Global.world_manager.current_world:
		#if activity_handler:
			#activity_handler.handle_input(event)
		#else:
			#if event is InputEventMouseButton and event.pressed:
				#match event.button_index:
					#MOUSE_BUTTON_LEFT:
						#if event.ctrl_pressed:
							#SignalBus.simple_interact.emit(true)
						#else:
							#SignalBus.simple_interact.emit(false)
					#MOUSE_BUTTON_RIGHT:
						#SignalBus.complex_interact.emit()
#
#
#func _process(_delta: float) -> void:
	#if Global.world_manager.current_world:
		#input_manager.BasicControls()
		#ui_manager.drag_fail_restore()
#
#
#func begin_async_operation() -> void:
	#pending_crisis_operation_count += 1
#
#
#func end_async_operation() -> void:
	#pending_crisis_operation_count -= 1
	#if pending_crisis_operation_count == 0:
		#SignalBus.operation_finished.emit()
	#
	#
##func no_pending_async_operation() -> bool:
	##if pending_crisis_operation_count == 0:
		##return true
	##else:
		##return false
#
#
#func handle_world_hover(tile: Vector3i) -> void:
	#if Input.is_action_pressed("Ctrl") and selected_char and not activity_handler:
		#var selected_weapon_activity: Activity = selected_char.get_selected_weapon_activity()
		#selected_weapon_activity.execute()
	#
	#if tile == last_hovered_tile:
		#return
#
	#last_hovered_tile = tile
#
	#if activity_handler:
		#if activity_handler.has_method("handle_hover"):
			#activity_handler.handle_hover(tile)
			#return
#
#
	#world_manager.hover_tile.set_tile(tile)
#
#
#func toggle_pause():
	#if pause_menu_active:
		#unpause_game()
	#else:
		#menu_instance = menu_scene.instantiate()
		#get_tree().current_scene.add_child(menu_instance)
		#get_tree().paused = true
		#pause_menu_active = true
#
#
#func unpause_game():
	#if menu_instance:
		#menu_instance.queue_free()
		#menu_instance = null
	#get_tree().paused = false
	#pause_menu_active = false
#
#
#func create_player_party():
	#var new_party = PartyData.new()
	#for creature in world_manager.current_world.creatures:
		#if creature.data.player_controlled:
			#new_party.members_by_uid.append(creature.data.uid)
#
#
#func wait_frame(amount: int = 1):
	#for i in range(amount):
		#await get_tree().process_frame
#
#
#func set_active_window(window: Node) -> void:
	#if active_window == window:
		#return
	#all_info_window.layer = 100
	#container_window.layer = 100
#
	#active_window = window
	#active_window.layer = 150
#
#
#func clear_data() -> void:
	#for child in game_session.world_container.get_children():
		#child.free()
	#world_manager.clear_data()
	#crisis_manager.clear_data()
	#door_manager.clear_data()
	#ai_manager.clear_data()
	#time_manager.clear_data()
	#selected_char = null
	#focus_char = null
#
#
#func setup() -> void:
	#add_child(all_info_window)
	#add_child(container_window)
	#add_child(world_info)
	#add_child(condition_viewer)
	#
	#all_info_window.visible = false
	#container_window.visible = false
	#world_info.visible = false
	#items_list = all_info_window.get_node("%ItemsList")
	#container_list = container_window.get_node("Control/ColorRect/VBoxContainer/ScrollContainer/ItemList")
	#await get_tree().create_timer(0.1).timeout
	#SignalBus.change_cursor.emit("default")
#
#
#func _ready() -> void:
	#randomize()
	#add_child(state_manager)
	#add_child(crisis_manager)
	#add_child(ui_manager)
	#add_child(dialog_manager)
	#add_child(input_manager)
	#add_child(overworld_manager)
	#add_child(world_manager)
	#add_child(cursor_manager)
	#add_child(ai_manager)
	#add_child(time_manager)
	#add_child(noise_manager)
	#add_child(door_manager)
	#add_child(reaction_manager)
	#add_child(map_manager)
#
	#call_deferred("setup")
