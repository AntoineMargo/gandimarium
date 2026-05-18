extends Effect
class_name AddConditionEffect

enum Behaviour {
	TOGGLE,
	RE_APPLY
}

@export var behaviour: Behaviour = Behaviour.TOGGLE
@export var condition: Condition = null

func apply(_source, _target, _degree: int = 2) -> void:
	pass

func apply_context(ctx: ActivityContext) -> void:
	ctx.shared_context.created_conditions.append(condition)
	ctx.condition = condition
	if behaviour == Behaviour.RE_APPLY and ctx.target.get_condition_by_id(condition.id):
		ctx.target.toggle_condition(ctx)
	ctx.target.toggle_condition(ctx)
