extends ContainerProp
class_name Crate

func _ready() -> void:
	scene = load("res://props/containers/crate.tscn")
	_on_ready()
	_initalize_container()
