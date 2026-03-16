extends Node2D
class_name Mover

var path : Array = []
var path_index: int = 0
var active : bool = false

var velocity := Vector2.ZERO
var max_speed : float = 0.0
var accel : float = 1500.0

var wm = null
var nm = null
var creature = null

func begin_path(new_path: Array):
	var was_moving = active and path_index < path.size()
	
	path = new_path
	path_index = 0
	active = true
	
	# Only snap if we're starting fresh (not already mid-movement)
	if not was_moving:
		var coords = creature.get_coords()
		global_position = wm.tile_to_pixels(coords)
	else:
		var current_tile = creature.get_coords()
		# If the new path starts from where we currently are, skip that tile
		if path.size() > 0 and path[0] == current_tile:
			path_index = 1

func stop():
	active = false
	path.clear()

func move_to_next_point(delta):
	
	var old_point = creature.get_coords()
	var point = path[path_index]

	wm.creatures_visible_if_on_layer()

	var target = wm.tile_to_pixels(point)

	var dir = (target - global_position).normalized()

	var desired = dir * max_speed

	velocity = velocity.move_toward(desired, accel * delta)
	
	global_position += velocity * delta

	if global_position.distance_to(target) <= max_speed * delta:
		arrive_at_tile(point, old_point)
		
	wm.selection_highlight.update_selection_highlight()

func arrive_at_tile(point, old_point):
	global_position = wm.tile_to_pixels(point)
	creature.set_coords(point)
	wm.try_move_char_abs(creature, old_point, point)
	if creature.data.player_controlled:
		SignalBus.noticing_check.emit(point)
	path_index += 1

func _on_stop_all_movement():
	var old_coords = creature.get_coords()
	var closest_tile = wm.pixels_to_tile(global_position)

	global_position = wm.tile_to_pixels(closest_tile)
	wm.try_move_char_abs(creature, old_coords, closest_tile)
	stop()

func _physics_process(delta: float) -> void:
	if not active:
		return

	if path_index >= path.size():
		stop()
		return

	#print("Position: ", position)
	move_to_next_point(delta)

func _ready() -> void:
	wm = Global.world_manager
	nm = Global.noise_manager
	creature = get_parent()
	SignalBus.stop_all_movement.connect(_on_stop_all_movement)
