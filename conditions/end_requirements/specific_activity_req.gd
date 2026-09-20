extends ConditionEndRequirement
class_name SpecificActivityEndRequirement

@export var identity: Enums.Identity

var activity_id: String = ""


func setup(condition: Condition):
	parent_condition = condition
	if condition.linked_activities.is_empty():
		return
	#activity_id = condition.linked_activities[0].id
	activity_id = condition.linked_activities[0].query_current_activity(condition.target).id
	#activity_id = condition.info.get("activity")
	counter += 1
	if not SignalBus.event.is_connected(handle_event):
		SignalBus.event.connect(handle_event)


func handle_event(reaction_event: ReactionEvent):
	if not event_types.has(reaction_event.type):
		return
	
	if identity == Enums.Identity.USER:
		if reaction_event.context.user != parent_condition.user:
			return
	elif identity == Enums.Identity.TARGET:
		if reaction_event.context.target != parent_condition.user.get_coords():
			return
	
	if event_types.has(Enums.EventType.ACTIVITY_COMPLETED) or event_types.has(Enums.EventType.ACTIVITY_STARTED):
		if not validate(reaction_event.context):
			return

	counter -= 1
	if counter == 0:
		parent_condition.request_cancel()
		#completed.emit()


func validate(ctx: ActivityContext) -> bool:
	if ctx.activity.id == activity_id:
		return true
	else:
		return false
