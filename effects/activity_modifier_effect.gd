extends Effect
class_name ActivityModifierEffect

@export var modifier: ActivityModifier = null

func apply(_source, target, _degree: int = 2) -> void:
	var new_modifier = modifier.duplicate()
	if target.has_method("add_activity_modifier"):
		target.add_activity_modifier(new_modifier)

func remove(_source, target, _degree):
	if target.has_method("remove_activity_modifier"):
		target.remove_activity_modifier(modifier)
