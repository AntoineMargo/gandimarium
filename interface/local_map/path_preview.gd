extends Node2D


@export var line_color: Color
@export var line_width: float = 2.0
@export var ap_tick_length: float = 6.0
@export var mp_per_ap: int = 5

var path_points: PackedVector2Array = []
var segment_costs: Array = []  # per-segment movement cost

func update_path(path: Array, tilemap: TileMapLayer, costs: Array) -> void:
	path_points.clear()
	segment_costs.clear()
	var tile_size: Vector2 = tilemap.tile_set.tile_size

	var current_level = Global.world_manager.current_level

	for idx in range(path.size()):
		var point = path[idx]
		if point.z != current_level:
			continue

		var cell_x = int(point.x / Global.TILE_SIZE)
		var cell_y = int(point.y / Global.TILE_SIZE)
		var cell = Vector2i(cell_x, cell_y)

		# map to local world coordinates
		path_points.append(tilemap.map_to_local(cell))

	# copy segment costs
	segment_costs = costs.duplicate()
	queue_redraw()

func _draw():
	if path_points.size() < 2:
		return

	var accumulated_mp = - 1.0
	var next_ap_threshold = mp_per_ap

	for i in range(path_points.size() - 1):
		var a = path_points[i]
		var b = path_points[i + 1]

		# draw main path segment
		draw_line(a, b, line_color, line_width)
		
		# accumulate MP cost
		if i < segment_costs.size():
			accumulated_mp += segment_costs[i]
		else:
			accumulated_mp += 1.0  # fallback if segment_costs missing

		# draw AP tick if threshold crossed
		if accumulated_mp >= next_ap_threshold and i + 1 < path_points.size():
			var mid = a.lerp(b, 0.5)  # midpoint of the segment
			var dir = (b - a).normalized()
			var perp = Vector2(-dir.y, dir.x)
			draw_line(mid - perp * ap_tick_length, mid + perp * ap_tick_length, line_color, line_width)

			# advance threshold for next AP
			next_ap_threshold += mp_per_ap
	
	for point in path_points:
		draw_circle(point, line_width / 2, line_color)
