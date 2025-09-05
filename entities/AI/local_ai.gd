extends Node

class_name LocalAI

var creature: Creature = null

func perform_routine():
	pass

func _ready() -> void:
	creature = get_parent().get_parent()
	SignalBus.local_turn_passed.connect(perform_routine)
