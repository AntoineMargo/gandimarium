extends Resource

class_name PlannedAct

var activity: Activity = null
var start_position: Vector3i = Vector3i.ZERO
var target_position: Vector3i = Vector3i.ZERO
var target_creature: Creature = null
var utility: int = 0
var hints = []

# Perception data
var nearby_enemies: Array = []
var visible_enemies: Array = []
var nearby_allies: Array = []
var visible_allies: Array = []

#func _init(name: String, level: int) -> void:
	#self.name = name
	#self.level = level
