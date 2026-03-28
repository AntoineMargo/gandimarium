extends Node2D
class_name VFX

static func spawn(scene: PackedScene, pos: Vector2, parent):
	var fx = scene.instantiate()
	fx.global_position = pos
	parent.add_child(fx)
	return fx
