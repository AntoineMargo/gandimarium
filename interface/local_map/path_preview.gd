extends Node2D

@export var line_width: float = 4.0
@export var ap_tick_length: float = 10.0
@export var line_color_transp: Color
@export var line_color: Color
@export var blocked_color: Color
@export var blocked_color_transp: Color
@export var mp_per_ap: float = 0.0
@export var max_available_ap: float = 0.0
@export var current_available_mp: float = 0

var path_points: Array = []
var segment_costs: Array = []

var line: Line2D
var shadow_line: Line2D
var ticks_container: Node2D
var tick_template: Node2D 
var tick_main: Line2D
var tick_shadow: Line2D

func get_char_data():
	var character = Global.selected_char

	mp_per_ap = character.get_stat("max_mp")
	max_available_ap = character.get_stat("current_ap")
	current_available_mp = character.get_stat("current_mp")
	print("lala")

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

	# determine color based on AP availability
	#var max_ap_mp: float = max_available_ap * mp_per_ap
	var cutoff_mp := current_available_mp
	var total_mp: float = 0.0
	for cost in segment_costs:
		total_mp += cost

	var grad = line.gradient

	if total_mp > cutoff_mp:
		grad.set_color(1, blocked_color)
	else:
		grad.set_color(1, line_color)

	update_ap_ticks()

func update_ap_ticks():
	clear_ticks()
	var accumulated_mp = 0.0
	
	# Calculate how much MP we have left in the current AP
	var mp_used_in_current_ap = mp_per_ap - current_available_mp
	# First threshold is when we need to spend our first NEW AP
	var next_ap_threshold = current_available_mp - (max_available_ap * mp_per_ap)
	var cutoff_mp = current_available_mp
	
	# Check if we're over the limit
	var total_mp := 0.0
	for c in segment_costs:
		total_mp += c
	var is_over_limit = total_mp > cutoff_mp
	#print("Limit: %.1f, used: %.1f" % [cutoff_mp, total_mp])
	#SignalBus.dialog_show_message.emit("Limit: %.1f, used: %.1f" % [cutoff_mp, total_mp])
	
	for i in range(path_points.size() - 1):
		var segment_cost = segment_costs[i] if i < segment_costs.size() else 1.0
		var new_accumulated = accumulated_mp + segment_cost
		
		# Check if crossing threshold with this segment
		if new_accumulated > next_ap_threshold:
			var a = path_points[i]
			var b = path_points[i + 1]
			var mid = a.lerp(b, 0.5)
			var dir = (b - a).normalized()
			var perp = Vector2(-dir.y, dir.x)
			var tick_start = mid - perp * ap_tick_length
			var tick_end = mid + perp * ap_tick_length
			
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
			
			# Set tick colors based on limit
			if is_over_limit:
				main.gradient.set_color(0, blocked_color_transp)
				main.gradient.set_color(1, blocked_color)
				main.gradient.set_color(2, blocked_color)
				main.gradient.set_color(3, blocked_color_transp)
			else:
				main.gradient.set_color(0, line_color_transp)
				main.gradient.set_color(1, line_color)
				main.gradient.set_color(2, line_color)
				main.gradient.set_color(3, line_color_transp)
			
			next_ap_threshold += mp_per_ap  # All subsequent ticks are mp_per_ap apart
		
		accumulated_mp = new_accumulated

func clear_ticks():
	for child in ticks_container.get_children():
		if child != tick_template:
			child.queue_free()

func clear_all():
	path_points.clear()
	segment_costs.clear()
	clear_ticks()
	line.points = []
	shadow_line.points = []

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
	SignalBus.clear_path_preview.connect(clear_all)
	#SignalBus.update_ui_for_char.connect(get_char_data)
