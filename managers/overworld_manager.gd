extends Node
class_name OverworldManager

var all_creatures_by_id: Dictionary = {}

func register_global_creature(creature):
	all_creatures_by_id[creature.data.id] = creature

func unregister_global_creature(creature):
	all_creatures_by_id.erase(creature.data.id)
