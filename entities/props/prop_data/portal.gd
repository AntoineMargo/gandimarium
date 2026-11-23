extends PropData
class_name PropDataPortal

@export var destination: Vector3i = Vector3i(29, 30 ,0)


## Setup here only sets the correct Z for the destionation variable.
func setup(ctx: Context) -> void:
	if ctx is ActivityContext and ctx.shared_context:
		var shared_context: SharedContext = ctx.shared_context
		if shared_context.created_maps.is_empty():
			return

		var map_data: MapData = shared_context.created_maps[0]
		destination.z = map_data.layer_ids[0]


func operate(creature: Creature):
	Global.world_manager.teleport(creature, destination)
