extends Node
class_name CentralAIController

func is_close(origin: Vector3i):
	for creature in Global.world_manager.current_world.creatures:
		var target = Global.world_manager.get_char_coords(creature)
		if WorldMath.dist_sq_weighted_3d(origin, target.vec3):
			if creature.senses_check_on_tile(target.vec3):
				for other_creature in Global.world_manager.current_world.creatures: # placeholder code starting from this line
					if other_creature.data.name == "Andimar":
						creature.data.relationships.hostile.append(other_creature)
