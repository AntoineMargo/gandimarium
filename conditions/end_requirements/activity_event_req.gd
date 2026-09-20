extends ConditionEndRequirement
class_name ActivityEventEndRequirement

@export var identity: Enums.Identity
@export var tags: Enums.Tag

func setup(condition: Condition):
	parent_condition = condition
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
	var act_tags: Array[Enums.Tag] = ctx.activity.tags
	for tag in tags:
		if not act_tags.has(tag):
			return false
	return true
