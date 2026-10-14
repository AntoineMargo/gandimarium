extends Resource
class_name PropRef

var map_id: String = ""
var pos: Vector3i = Vector3i(-1, -1, -1)

var prop: Prop = null


func get_prop() -> Prop:
	if is_instance_valid(prop):
		return prop

	prop = null
	return null


func _init(m: String, p: Vector3i, node: Prop) -> void:
	map_id = m
	pos = p
	prop = node
