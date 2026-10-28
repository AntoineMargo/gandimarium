extends Resource
class_name PropRef

var map_id: String = ""
var pos: Vector3i = Vector3i(-1, -1, -1)

func get_prop() -> Prop:
	return null


func _init(m: String, p: Vector3i) -> void:
	map_id = m
	pos = p
	#prop = node


#var prop: Prop = null


#func get_prop() -> Prop:
	#if is_instance_valid(prop):
		#return prop
#
	#prop = null
	#return null
