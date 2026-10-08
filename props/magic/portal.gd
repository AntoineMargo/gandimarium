extends Prop
class_name PortalProp

@export var destination: Vector3i = Vector3i(29, 30 ,0)

func setup(ctx: Context) -> void:
	var map_data: MapData = ctx.created_maps[0]
	var layer_id: int = map_data.layer_ids[0]
	destination.z = layer_id


func operate(creature: Creature):
	Global.world_manager.teleport(creature, destination)

#func operate(creature: Creature):
	#Global.world_manager.teleport(creature, Vector3i(29, 30, 1500))
