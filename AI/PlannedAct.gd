extends Resource

class_name PlannedAct

var activity: Activity = null
var start_position: Vector3i = Vector3i.ZERO
var target_position: Vector3i = Vector3i.ZERO
var target_creature: Creature = null
var utility: int = 0
var hints = []

#func _init(name: String, level: int) -> void:
	#self.name = name
	#self.level = level
