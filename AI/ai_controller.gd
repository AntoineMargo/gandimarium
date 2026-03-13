extends Node
class_name AIController

var wm = null
var creature: Creature = null

var current_state = null

var overmapai: OvermapAI
var localai: LocalAI
var crisisai: CrisisAI

func switch_state(new_state):
	#if current_state != null:
		#current_state.set_process(false)
		#current_state.set_physics_process(false)
		#current_state.on_exit()

	current_state = new_state
	
	#current_state.on_enter()
	#current_state.set_process(true)
	#current_state.set_physics_process(true)

func _ready() -> void:
	wm = Global.world_manager
	creature = $".."
	overmapai = $OvermapAI
	localai = $LocalAI
	crisisai = $CrisisAI
	current_state = crisisai
