extends Resource
class_name ReactionEvent

var type: Enums.EventType = Enums.EventType.ACTIVITY_STARTED
var context: Context
var data = {}
var consumed = false

static func movement(ctx: Context) -> ReactionEvent:
	var event = ReactionEvent.new()
	event.type = Enums.EventType.MOVEMENT
	event.context = ctx
	return event

@warning_ignore("shadowed_variable")
static func activity_started(ctx: Context) -> ReactionEvent:
	var event = ReactionEvent.new()
	event.type = Enums.EventType.ACTIVITY_STARTED
	event.context = ctx
	return event
