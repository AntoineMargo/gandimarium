extends Effect
class_name FlashTileEffect

@export var colour: Color = Color(0.957, 0.459, 0.212, 1.0)


func apply(_source, target, _degree: int = 2) -> void:
	var layer_tile: Vector2i = Vector2i(target.x, target.y)
	Global.world_manager.flash_tile_overlay(layer_tile, colour)




#func apply_context(ctx: Context) -> bool:
	#var effect_origin: Vector3i
	#
	#if ctx is ActivityContext:
		#effect_origin = ctx.user.get_coords()
		#var tiles: Array[Vector3i] = ctx.activity.compute_affected_area(effect_origin)
		#for tile in tiles:
			#var layer_tile: Vector2i = Vector2i(tile.x, tile.y)
			#Global.world_manager.flash_tile_overlay(layer_tile, colour)
		#return true
	#else:
		#return false


#func apply_context(ctx: Context) -> bool:
	#var effect_origin: Vector3i
	#
	#if ctx is ActivityContext:
		#if ctx.target is Entity:
			#effect_origin = ctx.target.get_coords()
		#else:
			#effect_origin = ctx.target
		#var tiles: Array[Vector3i] = ctx.activity.compute_affected_area(effect_origin)
		#for tile in tiles:
			#var layer_tile: Vector2i = Vector2i(tile.x, tile.y)
			#Global.world_manager.flash_tile_overlay(layer_tile, colour)
		#return true
	#else:
		#return false
