extends Resource
class_name SavedLayer

@export var layer_id: int
@export var tiles: Array[SavedTileContents] = []

func _init(z: int = 0) -> void:
	layer_id = z
