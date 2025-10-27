extends Resource

class_name PlannedAct

@export var activity: Activity = null
@export var target_position: Vector3i = Vector3i.ZERO

var target_creature: Creature = null

@export var hints = []
