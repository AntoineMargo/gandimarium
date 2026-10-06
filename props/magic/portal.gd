extends Prop
class_name PortalProp

func operate(creature: Creature):
	Global.world_manager.teleport(creature, Vector3i(29, 30, 1500))
