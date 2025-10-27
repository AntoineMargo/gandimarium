extends Node

var wm = Global.world_manager

var creature: Creature = null
var target: Creature = null

func movement_planner():
	


func path_to_target_adjacency():
	var origin = wm.get_char_coords(target)
	var goal = wm.get_char_coords(creature)
	var path = wm.get_multi_level_path(origin.vec3, goal.vec3)
	
	if path.size() < 2 and path[-1] != target:
		return
		
	path.reverse()
	path.pop_back()

	var cost = wm.calculate_path_cost_3D(path)
	
	if cost <= creature.data.current_mp:
		
