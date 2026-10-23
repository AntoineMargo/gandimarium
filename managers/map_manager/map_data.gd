extends Resource
## Runtime object exclusively.
class_name MapData

var id: int = 0
var root: Map = null
var name: String = ""
var base_z: int
var layer_ids: Array[int] = []


func get_map() -> Map:
	if is_instance_valid(root):
		return root

	root = null
	return null


func destroy_self() -> void:
	var map: Map = get_map()
	if map and map.has_method("destroy_self"):
		map.destroy_self()
	Global.map_manager.remove_map(id)
