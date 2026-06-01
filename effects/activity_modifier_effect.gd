extends Effect
class_name ActivityModifierEffect

@export var modifier: Modifier = null

func apply_context(ctx: Context) -> void:
	var instance = modifier.duplicate(true)
	instance.owner = ctx.target
	ctx.target.data.activity_modifiers.append(instance)
	if ctx.condition:
		ctx.condition.linked_modifiers.append(instance)
	if ctx is ActivityContext and ctx.shared_context and not ctx.shared_context.created_conditions.is_empty():
		for condition in ctx.shared_context.created_conditions:
			condition.linked_modifiers.append(instance)

#func apply(_source, target, _degree: int = 2) -> void:
	#var new_modifier = modifier.duplicate()
	#if target.has_method("add_activity_modifier"):
		#target.add_activity_modifier(new_modifier)
#
#func remove(_source, target, _degree):
	#if target.has_method("remove_activity_modifier"):
		#target.remove_activity_modifier(modifier)

#func apply_context(ctx: Context) -> void:
	#var wm = Global.world_manager
	#var creature_instance: Creature = wm.spawn_character(creature_data_path, ctx.target)
	#ctx.created_creatures.append(creature_instance)
	#if ctx is ActivityContext and ctx.condition:
		#ctx.condition.linked_creatures.append(creature_instance)
	#if ctx.shared_context and not ctx.shared_context.created_conditions.is_empty():
		#for condition in ctx.shared_context.created_conditions:
			#condition.linked_creatures.append(creature_instance)
