extends Resource
class_name HTNPrimitive

@export var activity_variant: ActivityVariant
@export var pre_executed: Activity
@export var hint: AIHint

func _init(p_activity: ActivityVariant = null, user: Creature = null):
		activity_variant = p_activity
		hint = activity_variant.activity.ai_hint
		if user:
			pre_executed = activity_variant.pre_execute(user)
