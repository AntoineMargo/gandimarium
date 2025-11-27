extends Node
class_name EvaluatorModule

var wm = null
var creature: Creature = null
var crisis_ai: CrisisAI = null

func activity_selector(sequences, report, entries):
	pass

func setup(world_manager, owner_creature: Creature, ai_controller: Node):
	wm = world_manager
	creature = owner_creature
	crisis_ai = ai_controller

func _ready() -> void:
	pass
