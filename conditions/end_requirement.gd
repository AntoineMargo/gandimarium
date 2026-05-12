@abstract
extends Resource
class_name ConditionEndRequirement

@export var event_types: Array[Enums.EventType]
@export var counter: int = -1

var parent_condition: Condition = null

func handle_event(reaction_event: ReactionEvent):
	if not event_types.has(reaction_event.type):
		return

	if counter == -1:
		return

	counter -= 1
	if counter == 0:
		parent_condition.request_cancel()

func setup(condition: Condition):
	parent_condition = condition
	if not SignalBus.event.is_connected(handle_event):
		SignalBus.event.connect(handle_event)

func dispose():
	if SignalBus.event.is_connected(handle_event):
		SignalBus.event.disconnect(handle_event)
	parent_condition = null
