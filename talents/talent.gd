extends Resource
class_name Talent

@export var name: String = "placeholder"
@export var description: String = "This is a placeholder description."
@export var icon: String
@export var filters: Array[Filter] = []
@export var effects: Array[Effect] = []
@export var supplanted: Array[Talent] = []

func initialize(target) -> void:
	for effect in effects:
		effect.apply(self, target, -1)
