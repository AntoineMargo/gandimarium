extends Effect
class_name AddConditionEffect

enum Recipient {
	TARGET,
	USER
}

@export var recipient: Recipient = Recipient.TARGET
@export var condition: Condition = null

func apply_context(ctx: Context) -> bool:
	if recipient == Recipient.TARGET:
		ctx.condition_recipient = ctx.target
	elif recipient == Recipient.USER:
		ctx.condition_recipient = ctx.user
	ctx.condition = condition
	if ctx.condition_recipient.get_condition_by_id(condition.id):
			return false
	var instance = ctx.condition_recipient.add_condition_from(ctx)
	if ctx is ActivityContext and ctx.shared_context:
		ctx.shared_context.created_conditions.append(instance)
	return true
