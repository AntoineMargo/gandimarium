extends Effect
class_name MoveEffect

@export var prop: PackedScene = null

#func apply_context(ctx: Context) -> bool:
	#if ctx.target is Vector3i:
		#var time: float = Global.world_manager.interact_move(ctx.user, ctx.target)
		#if Global.crisis_manager.crisis_mode:
			#await Global.get_tree().create_timer(time).timeout
	#return true


func apply_context(ctx: Context) -> bool:
	if ctx.target is Vector3i:
		Global.world_manager.interact_move(ctx.user, ctx.target)
	return true
