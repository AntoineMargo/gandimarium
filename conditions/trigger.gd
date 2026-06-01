extends Resource
class_name Trigger

@export var event_type: Enums.EventType = Enums.EventType.ACTIVITY_COMPLETED
#@export var self_involvement: Enums.Involvement = Enums.Involvement.EITHER
@export var event_filters: Array[TriggerFilter] = []
@export var effects: Array[Effect] = []

func process_trigger(event: ReactionEvent, owner: Entity = null) -> bool:
	if verify(event, owner):
		for effect in effects:
			var ctx = Context.new()
			ctx.user = owner
			ctx.origin = owner.get_coords()
			ctx.target = owner
			if effect.has_method("apply_context"):
				effect.apply_context(ctx)
			else:
				effect.apply(self, ctx.target)
		return true
	return false

func verify(event: ReactionEvent, owner: Entity = null) -> bool:
	if not event.type == event_type:
		return false

	for filter in event_filters:
		if not filter.is_satisfied(event.context, owner):
			return false

	return true
