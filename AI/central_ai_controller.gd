extends Node
class_name CentralAIController

func is_close(origin: Vector2i):
	for creature in Global.world_manager.current_world.creatures:
		var target = Vector2i(creature.data.tile_x, creature.data.tile_y) 
		if WorldMath.pos_in_range_squared(origin, target, 40):
			if creature.check_senses():
				for other_creature in Global.world_manager.current_world.creatures: # placeholder code starting from this line
					if other_creature.data.name == "Andimar":
						creature.data.relationships.hostile.append(other_creature)
