extends Effect
class_name AddConditionEffect

@export var condition: Condition = null

func apply(_source, _target, _degree: int = 2) -> void:
	pass

func apply_context(ctx: ActivityContext) -> void:
	ctx.condition = condition
	ctx.target.toggle_condition(ctx)
