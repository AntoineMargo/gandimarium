extends Effect
class_name ConditionEffect

@export var condition: Condition = null

func apply(_source, _target, _degree: int = 2) -> void:
	pass
	#target.toggle_condition(condition, source)

func apply_context(ctx: ActivityContext) -> void:
	ctx.target.toggle_condition(condition, ctx)
