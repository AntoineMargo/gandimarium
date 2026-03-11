extends Effect
class_name StateEffect

@export var induced_state: Enums.State

func apply(_source, target, _degree: int = 2) -> void:
	if target is Creature:
		target.data.state = induced_state
		SignalBus.update_character_info.emit()

func remove(_source, target, _degree):
	if target is Creature:
		target.data.state = target.get_best_state()
		SignalBus.update_character_info.emit()
