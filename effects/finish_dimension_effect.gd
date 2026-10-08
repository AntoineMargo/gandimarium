extends Effect
## Must be linked to a condition and used with CreateDimensionEffect and CreatePropEffect with a portal.
class_name FinishDimensionEffect

func apply_context(ctx: Context) -> bool:
	if ctx.created_maps.is_empty() or ctx.created_props.is_empty():
		return false

	var pocket_dimension: Map = ctx.created_maps[0].root
	var portal: Prop = ctx.created_props[0]
	
	if portal is not PortalProp:
		return false
	
	pocket_dimension.portal_location = portal.get_coords()
	return true
