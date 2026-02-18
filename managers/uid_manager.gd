extends Node
class_name UIDManager

enum Type {
	CREATURE,
	PROP,
	TILE
	}

var wm = null
var uid_state = null

func next_uid(type: Type) -> int:
	if type == Type.CREATURE:
		return uid_state.get_creature_next()
	if type == Type.PROP:
		return uid_state.get_prop_next(wm.current_world.id)
	if type == Type.TILE:
		return uid_state.get_tile_next(wm.current_world.id)
	push_error("Error: ID could not be successfully produced")
	return -1

func init_uid_state_for_map():
	var props = get_all_props()
	var map_id = wm.current_world.id
	var max_uid: int = -1
	for prop in props:
		if prop.is_runtime == false:
			max_uid = max(max_uid, prop.uid)

	uid_state.set_prop_next(map_id, max_uid) 

func get_all_props() -> Array:
	var root = wm.current_world
	if not root:
		push_error("No scene open!")
		return []

	var props = _get_all_props(root)
	return props

func _get_all_props(node: Node) -> Array:
	var result = []
	for child in node.get_children():
		if child is Prop:
			result.append(child)
		# recurse into children
		result += _get_all_props(child)
	return result

func _ready() -> void:
	uid_state = UIDState.new()
	wm = Global.world_manager
