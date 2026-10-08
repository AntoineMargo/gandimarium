extends Resource
class_name MapData

var id: int
var root: Node
var base_z: int
var layer_ids: Array[int] = []

func destroy_self() -> void:
	if root.has_method("destroy_self"):
		root.destroy_self()
	Global.map_manager.remove_map(id)
