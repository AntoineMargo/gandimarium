extends ConditionEndRequirement
class_name ActivityCompletedEndRequirement

@export var identity: Enums.Identity

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

	counter -= 1
	if counter == 0:
		parent_condition.request_cancel()
		#completed.emit()
