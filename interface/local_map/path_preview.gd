extends Node2D

@export var ap_tick_length: float = 3.0
@export var mp_per_ap: float = 5.0

var path_points: Array = []
var segment_costs: Array = []

var line_container: Node2D
var ticks_container: Node2D
var line_template: ColorRect
var tick_template: ColorRect

func _ready():
	line_container = $LineContainer
	ticks_container = $TicksContainer
	line_template = $LineTemplate
	tick_template = $TickTemplate
	line_template.visible = false
	tick_template.visible = false

func update_path(path: Array, tilemap: TileMapLayer, costs: Array) -> void:
	path_points.clear()
	segment_costs.clear()

	var current_level = Global.world_manager.current_level

	# convert tile positions to local
	for point in path:
		if point.z != current_level:
			continue
		var cell = Vector2i(int(point.x / Global.TILE_SIZE), int(point.y / Global.TILE_SIZE))
		path_points.append(tilemap.map_to_local(cell))

	segment_costs = costs.duplicate()

	update_segments()
	update_ap_ticks()

func clear_segments():
	for child in line_container.get_children():
		if child != line_template:
			child.queue_free()

func update_segments():
	clear_segments()
	if path_points.size() < 2:
		return

	for i in range(path_points.size() - 1):
		var a = path_points[i]
		var b = path_points[i + 1]

		var seg = line_template.duplicate() as ColorRect
		seg.visible = true
		seg.size = Vector2(a.distance_to(b), seg.size.y)  # keep height from template
		seg.position = a + Vector2(seg.size.x, 0) * 0.0  # adjust if needed
		seg.rotation = (b - a).angle()
		line_container.add_child(seg)

func clear_ticks():
	for child in ticks_container.get_children():
		if child != tick_template:
			child.queue_free()

func update_ap_ticks():
	clear_ticks()
	var accumulated_mp = -1.0
	var next_ap_threshold = mp_per_ap

	for i in range(path_points.size() - 1):
		accumulated_mp += segment_costs[i] if i < segment_costs.size() else 1.0
		if accumulated_mp >= next_ap_threshold and i + 1 < path_points.size():
			var a = path_points[i]
			var b = path_points[i + 1]
			var mid = a.lerp(b, 0.5)
			var dir = (b - a).normalized()
			var perp = Vector2(-dir.y, dir.x)

			var tick = tick_template.duplicate() as ColorRect
			tick.visible = true
			tick.position = mid - tick.size * 0.5  # center tick
			tick.rotation = perp.angle()
			ticks_container.add_child(tick)

			next_ap_threshold += mp_per_ap
