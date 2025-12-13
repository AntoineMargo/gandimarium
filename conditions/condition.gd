extends Resource

class_name Condition

@export var name: String = "placeholder"
@export var description: String = "This is a placeholder description."
@export var icon: String
@export var filters: Array[Filter] = []
@export var effects: Array[Effect] = []
@export var supplanted: Array[Condition] = []
@export var duration: int = -1

var concentration: Concentration = null
var user = null
var target = null
var source = null

func _on_concentration_ended():
	target.remove_condition(self)

func initialize(target) -> void:
	self.target = target
	if concentration and not concentration.ended.is_connected(_on_concentration_ended):
		concentration.ended.connect(_on_concentration_ended)
	for effect in effects:
		effect.apply(self, target, -1)

#func remove():
	#pass
