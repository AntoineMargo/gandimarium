extends Node2D
@export var line_width: float = 4.0
@export var ap_tick_length: float = 10.0
@export var mp_per_ap: float = 5.0
@export var max_available_ap: int = 3
@export var line_color_transp: Color
@export var line_color: Color
@export var blocked_color: Color
@export var blocked_color_transp: Color
var path_points: Array = []
var segment_costs: Array = []
var line: Line2D
var shadow_line: Line2D
var ticks_container: Node2D
var tick_template: Node2D 
var tick_main: Line2D
var tick_shadow: Line2D

func update_path(path: Array, tilemap: TileMapLayer, costs: Array) -> void:
	path_points.clear()
	segment_costs.clear()
	var current_level = Global.world_manager.current_level
	for point in path:
		if point.z != current_level:
			continue
		var cell = Vector2i(int(point.x / Global.TILE_SIZE), int(point.y / Global.TILE_SIZE))
		path_points.append(tilemap.map_to_local(cell))
	segment_costs = costs.duplicate()
	
	# update line points
	line.points = path_points
	shadow_line.points = path_points
	
	# Calculate total distance and MP cutoff
	var max_ap_mp = max_available_ap * mp_per_ap
	var total_mp = 0.0
	for cost in segment_costs:
		total_mp += cost
	
	# Calculate the position along the path where we exceed the limit
	var accumulated_mp = 0.0
	var total_distance = 0.0
	var cutoff_distance = 0.0
	var found_cutoff = false
	
	# First pass: calculate total distance and find cutoff point
	for i in range(path_points.size() - 1):
		var segment_distance = path_points[i].distance_to(path_points[i + 1])
		var segment_mp = segment_costs[i] if i < segment_costs.size() else 1.0
		
		if not found_cutoff:
			if accumulated_mp + segment_mp > max_ap_mp:
				# Cutoff is within this segment
				var mp_remaining = max_ap_mp - accumulated_mp
				var proportion = mp_remaining / segment_mp if segment_mp > 0 else 0.0
				cutoff_distance = total_distance + (segment_distance * proportion)
				found_cutoff = true
			else:
				accumulated_mp += segment_mp
		
		total_distance += segment_distance
	
	# Set up gradient based on cutoff
	var grad = line.gradient
	
	if total_mp <= max_ap_mp:
		# Entire path is within limit - all green
		# Remove extra gradient points if they exist
		while grad.get_point_count() > 2:
			grad.remove_point(grad.get_point_count() - 1)
		
		grad.set_offset(0, 0.0)
		grad.set_color(0, line_color)
		grad.set_offset(1, 1.0)
		grad.set_color(1, line_color)
	else:
		# Path exceeds limit - transition from green to red
		if total_distance > 0:
			var cutoff_ratio = cutoff_distance / total_distance
			
			# Ensure we have exactly 4 gradient points
			while grad.get_point_count() < 4:
				grad.add_point(0.5, line_color)
			while grad.get_point_count() > 4:
				grad.remove_point(grad.get_point_count() - 1)
			
			# Green section
			grad.set_offset(0, 0.0)
			grad.set_color(0, line_color)
			
			# Transition point (just before cutoff)
			grad.set_offset(1, max(0.0, cutoff_ratio - 0.01))
			grad.set_color(1, line_color)
			
			# Transition point (just after cutoff)
			grad.set_offset(2, min(1.0, cutoff_ratio + 0.01))
			grad.set_color(2, blocked_color)
			
			# Red section
			grad.set_offset(3, 1.0)
			grad.set_color(3, blocked_color)
		else:
			# Fallback if distance is 0
			while grad.get_point_count() > 2:
				grad.remove_point(grad.get_point_count() - 1)
			grad.set_offset(0, 0.0)
			grad.set_color(0, blocked_color)
			grad.set_offset(1, 1.0)
			grad.set_color(1, blocked_color)
	
	update_ap_ticks()

func clear_ticks():
	for child in ticks_container.get_children():
		if child != tick_template:
			child.queue_free()

func update_ap_ticks():
	clear_ticks()
	var accumulated_mp = 0.0
	var next_ap_threshold = mp_per_ap
	var max_ap_mp := max_available_ap * mp_per_ap
	
	for i in range(path_points.size() - 1):
		var segment_mp = segment_costs[i] if i < segment_costs.size() else 1.0
		
		# Check if we cross an AP threshold in this segment
		while accumulated_mp + segment_mp >= next_ap_threshold and i + 1 < path_points.size():
			var a = path_points[i]
			var b = path_points[i + 1]
			
			# Calculate position within segment where threshold is crossed
			var mp_into_segment = next_ap_threshold - accumulated_mp
			var lerp_t = mp_into_segment / segment_mp if segment_mp > 0 else 0.5
			
			var tick_pos = a.lerp(b, lerp_t)
			var dir = (b - a).normalized()
			var perp = Vector2(-dir.y, dir.x)
			var tick_start = tick_pos - perp * ap_tick_length
			var tick_end = tick_pos + perp * ap_tick_length
			
			var tick := tick_template.duplicate()
			tick.visible = true
			ticks_container.add_child(tick)
			var main = tick.get_node("Main") as Line2D
			var shadow = tick.get_node("Shadow") as Line2D
			
			var num_points = 10
			var points = []
			for j in range(num_points + 1):
				var t = float(j) / num_points
				points.append(tick_start.lerp(tick_end, t))
			main.points = points
			shadow.points = points
			
			# Create a NEW gradient for this tick to avoid shared reference issues
			var new_gradient = Gradient.new()
			
			# Set tick color based on whether THIS SPECIFIC tick is beyond the limit
			var is_beyond_limit = next_ap_threshold > max_ap_mp
			
			if is_beyond_limit:
				new_gradient.set_offset(1, 0.5)
				new_gradient.add_point(1.0, blocked_color_transp)
				new_gradient.set_color(0, blocked_color_transp)
				new_gradient.set_color(1, blocked_color)
			else:
				new_gradient.set_offset(1, 0.5)
				new_gradient.add_point(1.0, line_color_transp)
				new_gradient.set_color(0, line_color_transp)
				new_gradient.set_color(1, line_color)
				
			main.gradient = new_gradient
			
			next_ap_threshold += mp_per_ap
		
		accumulated_mp += segment_mp

func _ready():
	line = $Line2D
	shadow_line = $ShadowLine2D
	ticks_container = $Ticks2D
	tick_template = $Ticks2D/Tick2D
	tick_main = $Ticks2D/Tick2D/Main
	tick_shadow = $Ticks2D/Tick2D/Shadow
	tick_template.visible = false
	shadow_line.position = Vector2(0.5, 0.5)
	tick_shadow.position = Vector2(0.5, 0.5)
