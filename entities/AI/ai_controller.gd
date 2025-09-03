extends Node

var creature: Creature = null

func _ready() -> void:
	creature = get_parent()
