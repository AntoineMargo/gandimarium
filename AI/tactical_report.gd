extends RefCounted
class_name TacticalReport

var needs_update: bool = true

var creature: Creature = null
var available_activities: Array[ActivityVariant] = []

var crisis: CrisisReport = null
