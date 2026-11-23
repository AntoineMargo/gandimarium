extends Effect
## Must be linked to a condition and used with CreateDimensionEffect and CreatePropEffect with a portal.
class_name FinishDimensionEffect

func apply_context(ctx: Context) -> bool:
	if ctx is ActivityContext and ctx.shared_context:
		var shared_context: SharedContext = ctx.shared_context
		if shared_context.created_maps.is_empty() or shared_context.created_props.is_empty():
			return false

		var pocket_dimension: Map = shared_context.created_maps[0].root
		var portal: Prop = shared_context.created_props[0]


		if portal.data is not PropDataPortal:
			return false

		pocket_dimension.portal_location = portal.data.pos

	return true
