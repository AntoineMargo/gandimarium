extends Node
class_name ReactionManager

#func get_nearby_creatures(reaction_event: ReactionEvent) -> Array:
	#var target = reaction_event.context.target
	#var location: Vector3i
	#if target is Entity:
		#location = target.get_coords()
	#else:
		#location = target
	#var area_tiles = WorldMath.get_burst_tiles(location, 12)
	#var area_entities = WorldMath.get_entities_from_tiles(area_tiles)
	#for i in range(area_entities.size() - 1, -1, -1):
		#if area_entities[i] is not Creature \
		#or area_entities[i] == reaction_event.context.user \
		#or area_entities[i].data.current_reactions <= 0 \
		#or not area_entities[i].data.reactions:
			#area_entities.remove_at(i)
	#return area_entities

func get_nearby_creatures(reaction_event: ReactionEvent) -> Array:
	var target = reaction_event.context.target
	var location: Vector3i
	if target is Entity:
		location = target.get_coords()
	else:
		location = target
	var area_tiles = WorldMath.get_burst_tiles(location, 12)
	var area_entities = WorldMath.get_entities_from_tiles(area_tiles)
	for i in range(area_entities.size() - 1, -1, -1):
		if area_entities[i] is not Creature:
			area_entities.remove_at(i)
	return area_entities

func elicit_reaction(reaction_event, creature) -> void:
	for condition in creature.data.conditions:
		for trigger in condition.triggers:
			trigger.process_trigger(reaction_event, creature)

	if creature == reaction_event.context.user \
	or creature.data.current_reactions <= 0 \
	or not creature.data.reactions:
		return

	for reaction in creature.data.reactions:
		if reaction.enabled == false:
			continue
		for trigger in reaction.triggers:
			if trigger == reaction_event.type:
				var target = reaction_event.context.target
				# the following needs to be the creature's responsability
				var activity = reaction.activity.query_current_activity(creature, target)
				creature.perform_activity(activity, target)
				creature.data.current_reactions -= 1
				return


func handle_event(reaction_event: ReactionEvent) -> void:
	var nearby_creatures = get_nearby_creatures(reaction_event)
	for creature in nearby_creatures:
		elicit_reaction(reaction_event, creature)

func _ready() -> void:
	SignalBus.event.connect(handle_event)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
