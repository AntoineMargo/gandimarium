extends Effect
## Must be linked to a condition.
class_name CreatePropEffect

@export var prop_id: String = ""


func apply_context(ctx: Context) -> bool:
	if ctx.target is Vector3i:
		var prop_data = Library.get_prop(prop_id)
		var prop: Prop = Global.world_manager.spawn_prop_at_pos_from_data(prop_data, ctx.target)
		#prop_inst = Global.world_manager.spawn_prop_at_pos(Library.get_prop(prop_id), ctx.target)
		ctx.created_props.append(prop)

		if ctx is ActivityContext and ctx.condition:
			prop.linked_condition = ctx.condition
			ctx.condition.linked_props.append(prop)
		if ctx.shared_context and not ctx.shared_context.created_conditions.is_empty():
			for condition in ctx.shared_context.created_conditions:
				prop_data.linked_condition = condition
				if prop not in condition.linked_props:
					condition.linked_props.append(prop)
		return true
	return false


#func apply_context(ctx: Context) -> bool:
	#var prop_instance: Prop = null
	#if ctx.target is Vector3i:
		#prop_instance = Global.world_manager.spawn_prop_scene(prop, ctx.target)
		#if prop_instance.has_method("setup"):
			#prop_instance.setup(ctx)
		#ctx.created_props.append(prop_instance)
		#
		#var prop_ref = PropRef.new(prop_instance.map_id, prop_instance.pos, prop_instance)
		#
		#if ctx is ActivityContext and ctx.condition:
			#prop_instance.linked_condition = ctx.condition
			#ctx.condition.linked_props.append(prop_ref)
		#if ctx.shared_context and not ctx.shared_context.created_conditions.is_empty():
			#for condition in ctx.shared_context.created_conditions:
				#prop_instance.linked_condition = condition
				#if prop_ref not in condition.linked_props:
					#condition.linked_props.append(prop_ref)
		#return true
	#return false


#func apply_context(ctx: Context) -> bool:
	#var prop_instance: Prop = null
	#if ctx.target is Vector3i:
		#prop_instance = Global.world_manager.spawn_prop_scene(prop, ctx.target)
		#if prop_instance.has_method("setup"):
			#prop_instance.setup(ctx)
		#ctx.created_props.append(prop_instance)
		#if ctx is ActivityContext and ctx.condition:
			#prop_instance.linked_condition = ctx.condition
			#ctx.condition.linked_props.append(prop_instance)
		#if ctx.shared_context and not ctx.shared_context.created_conditions.is_empty():
			#for condition in ctx.shared_context.created_conditions:
				#prop_instance.linked_condition = condition
				#if prop_instance not in condition.linked_props:
					#condition.linked_props.append(prop_instance)
		#return true
	#return false
