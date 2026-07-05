extends Resource
class_name ScheduledStep

var slot: HTNPrimitiveSlot
var activity: ActivityVariant
var pre_executed: Activity
var hint: AIHint
#var skip: Enums.Skip

func _init(p_slot: HTNPrimitiveSlot = null, 
	p_activity: ActivityVariant = null, user: Creature = null):
	slot = p_slot
	activity = p_activity
	hint = activity.activity.ai_hint
	if user:
		pre_executed = activity.pre_execute(user)
