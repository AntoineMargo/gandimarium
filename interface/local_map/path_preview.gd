extends Node2D

@export var line_color: Color
@export var line_width: float = 4.0
@export var ap_tick_length: float = 3.0
@export var mp_per_ap: float = 5.0

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

	update_ap_ticks()

func clear_ticks():
	for child in ticks_container.get_children():
		if child != tick_template:
			child.queue_free()

func update_ap_ticks():

	clear_ticks()

	var accumulated_mp = -1.0
	var next_ap_threshold = mp_per_ap

	for i in range(path_points.size() - 1):

		if i < segment_costs.size():
			accumulated_mp += segment_costs[i]
		else:
			accumulated_mp += 1.0

		if accumulated_mp >= next_ap_threshold and i + 1 < path_points.size():

			var a = path_points[i]
			var b = path_points[i + 1]

			var mid = a.lerp(b, 0.5)
			var dir = (b - a).normalized()
			var perp = Vector2(-dir.y, dir.x)

			var p1 = mid - perp * ap_tick_length
			var p2 = mid + perp * ap_tick_length

			# duplicate template
			var tick := tick_template.duplicate()
			tick.visible = true
			ticks_container.add_child(tick)

			#tick.points = [p1, p2]
			var main = tick.get_node("Main") as Line2D
			var shadow = tick.get_node("Shadow") as Line2D

			main.points = [p1, p2]
			shadow.points = [p1, p2]

			next_ap_threshold += mp_per_ap

func _ready():
	line = $Line2D
	shadow_line =  $ShadowLine2D
	ticks_container = $Ticks2D
	tick_template = $Ticks2D/Tick2D
	tick_main = $Ticks2D/Tick2D/Main
	tick_shadow = $Ticks2D/Tick2D/Shadow
	tick_template.visible = false
	shadow_line.position = Vector2(0.5, 0.5)
	tick_shadow.position = Vector2(0.5, 0.5)
