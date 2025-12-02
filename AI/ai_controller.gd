extends Node

class_name AIController

var wm = null
var creature: Creature = null

var current_state = null

var overmapai: OvermapAI
var localai: LocalAI
var crisisai: CrisisAI

func _ready() -> void:
	creature = get_parent()
	overmapai = $OvermapAI
	localai = $LocalAI
	crisisai = $CrisisAI
	current_state = crisisai
	
	wm = Global.world_manager
	for child in get_children():
		if child.has_method("setup"):
			child.setup(wm, creature)
