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

#static func target_resolved(ctx: Context) -> ReactionEvent:
	#var event = ReactionEvent.new()
	#event.type = Enums.EventType.TARGET_RESOLVED
	#event.context = ctx
	#return event

static func activity_completed(ctx: Context) -> ReactionEvent:
	var event = ReactionEvent.new()
	event.type = Enums.EventType.ACTIVITY_COMPLETED
	event.context = ctx
	return event
