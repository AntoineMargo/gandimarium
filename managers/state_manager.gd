extends Node
class_name StateManager

var game_state = null
var current_map_id = ""

func get_map_state(map_id: String) -> MapState:
	if not game_state.map_states.has(map_id):
		game_state.map_states[map_id] = MapState.new()
	return game_state.map_states[map_id]

func get_map_delta(map_id: String) -> MapDelta:
	var map_state = get_map_state(map_id)
	return map_state.map_delta

func add_prop_to_delta(prop: Prop) -> void:
	var map_delta = get_map_delta(current_map_id)
	var prop_delta = prop.make_delta()
	var key = prop.pos

	if map_delta.removed_props.has(key):
		map_delta.removed_props.erase(key)

	if map_delta.added_props.has(key):
		return
	else:
		map_delta.added_props[key] = prop_delta

func remove_prop_from_delta(prop: Prop) -> void:
	var map_delta = get_map_delta(current_map_id)
	var key = prop.pos

	if map_delta.added_props.has(key):
		map_delta.added_props.erase(key)
		return

	# Cancel modification
	if map_delta.modified_props.has(key):
		map_delta.modified_props.erase(key)

	map_delta.removed_props[key] = true

func on_prop_modified(prop: Prop) -> void:
	var map_delta = get_map_delta(current_map_id)
	var key = prop.pos

	if map_delta.added_props.has(key):
		map_delta.added_props[key] = prop.make_delta()
	else:
		map_delta.modified_props[key] = prop.make_delta()

func save_game_state():
	
	var dir_path = "res://saved/game_state/"
	var path = "%s/%s.tres" % [dir_path, "game_state"]

	var dir = DirAccess.open("res://saved/")
	if not dir.dir_exists("game_state"):
		dir.make_dir("game_state")

	var err = ResourceSaver.save(game_state, path)

	if err != OK:
		push_error("Failed to save game state: %s" % err)
	else:
		print("SAVED!")
		
func load_game_state():
	pass

func _setup_map_state():
	if Global.world_manager.current_world:
		current_map_id = Global.world_manager.current_world.id

func _ready():
	if not game_state:
		game_state = GameState.new()
	SignalBus.world_ready.connect(_setup_map_state)
