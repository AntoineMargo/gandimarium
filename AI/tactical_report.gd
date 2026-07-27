extends RefCounted
class_name TacticalReport

var needs_update: bool = true

var creature: Creature = null

var available_activities: Array[ActivityVariant] = []

var favored_melee_attack: ActivityVariant = null
var favored_ranged_attack: ActivityVariant = null

var crisis: CrisisReport = null
