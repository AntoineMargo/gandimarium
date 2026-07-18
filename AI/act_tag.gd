extends Resource
class_name ActTag

@export var tag: Enums.ActivityTag
@export_range(0, 100) var value: int = 100
@export var weight: float = 1.0

func create(p_tag: Enums.ActivityTag, p_value: int, p_weight: float = 1.0) -> void:
	tag = p_tag
	value = p_value
	weight = p_weight
