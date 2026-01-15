extends Node
class_name AIManager

func noticing_check(origin: Vector3i):
	var wm = Global.world_manager
	for creature in Global.world_manager.current_world.creatures:
		if creature.data.player_controlled == false:
			var self_coords = Global.world_manager.get_char_coords(creature)
			if WorldMath.pos_in_range_weighted_3d(self_coords.vec3, origin, 40):
				if creature.senses_check_on_tile(origin):
					var potential_creature = wm.find_creature_on_tile(origin)
					creature.discover_creature(potential_creature)
					creature.evaluate_entering_crisis(potential_creature)

func _ready() -> void:
		SignalBus.noticing_check.connect(noticing_check)
