extends Node

class_name CrisisManager

const CRITICAL_SUCCESS_THRESHOLD = 10
const SUCCESS_THRESHOLD = 0
const FAILURE_THRESHOLD = -10

var crisis_mode: bool = false
var crisis_turn: int = 0

var activity_mode: Activity = null
#var activity_user: Node = null

func try_perform_activity(activity):
	if not crisis_mode:
		SignalBus.dialog_show_message.emit("You are not in crisis mode!")
		return
	if not Global.focus_char:
		return
		
	if not enough_action_points_for_activity(activity):
		return

	activity.execute(Global.focus_char)
	SignalBus.update_ui_for_char.emit()

func forward_unhandled_input(event: InputEvent) -> void:
	if activity_mode != null:
		activity_mode.handle_input(event)

func end_turn():
	if crisis_mode == true:
		crisis_turn += 1
		SignalBus.dialog_end_turn.emit()
		SignalBus.turn_ends.emit()
		SignalBus.update_ui_for_char.emit()
		SignalBus.refresh_reachable_tiles.emit()

func toggle_crisis(creature):
	if crisis_mode == false:
		start_crisis(creature)
	else:
		SignalBus.turn_ends.emit()
		SignalBus.update_ui_for_char.emit()
		SignalBus.refresh_reachable_tiles.emit()
		end_crisis(creature)

func start_crisis(creature):
	if crisis_mode == false:
		#print("Creature triggering crisis: ", creature.data.name)
		crisis_mode = true
		crisis_turn = 0
		SignalBus.toggle_end_turn_button.emit()
		SignalBus.dialog_start_crisis_mode.emit()

func end_crisis(creature):
	if crisis_mode == true:
		crisis_mode = false
		crisis_turn = 0
		SignalBus.toggle_end_turn_button.emit()
		SignalBus.dialog_end_crisis_mode.emit()

var slash = [0, 1, 2, 3]
var pierce = [0, 0, 2, 4]
var crush = [0, 0, 3, 3]
var throw = [0, 0, 2, 4]

func determine_degree_success(number: int):
	if number >= CRITICAL_SUCCESS_THRESHOLD:
		return 3  # Critical success
	elif number >= SUCCESS_THRESHOLD:
		return 2  # Normal success
	elif number >= FAILURE_THRESHOLD:
		return 1  # Failure
	else:
		return 0  # Critical failure

func determine_damage_wpn(dice_number: int, damage_die: int, damage_bonus: int, degree_success: int, attack_type: int) -> int:
	#var type_array: Array = get(attack_type)
	SignalBus.dialog_attack_type_selected.emit(attack_type)
	var multiplier: int = 0
	match attack_type:
		1: multiplier = slash[degree_success]
		2: multiplier = pierce[degree_success]
		3: multiplier = crush[degree_success]
		4: multiplier = throw[degree_success]
	if multiplier == 0:
		return 0

	dice_number *= multiplier

	var total_damage := 0
	for i in range(dice_number):
		total_damage += randi_range(1, damage_die)
	print("Degree of success: ", degree_success)
	print("Dice number: ", dice_number)
	print("Damage die: ", damage_die)
	print("Damage rolled: ", total_damage)

	total_damage += damage_bonus
	return total_damage

func determine_damage(dice_number: int, damage_die: int, damage_bonus: int, degree_success: int) -> int:
	var total_damage: int = 0
	if degree_success == 0:
		return (0)
	dice_number *= degree_success
	for die in range(dice_number):
		total_damage += randi_range(1, damage_die)
	total_damage += damage_bonus
	return (total_damage)

func meets_brawn_requirements(user: Node, weapon: Weapon, other: Weapon) -> bool:
	if weapon.brawn_req_1h >= 0 and user.data.brawn >= weapon.brawn_req_1h:
		return true
	if user.data.brawn >= weapon.brawn_req_2h and other == null:
		return true
	return false

func shape_burst(target_entities, user, range):
	for creature in Global.world_manager.current_world.creatures:
		var distance_ok = is_in_range(user, creature, range)
		var visible = has_line_of_sight(user, creature)
		if distance_ok and visible:
			target_entities.append(creature)

func is_in_range(user: Node, target: Node, range: int) -> bool:
	#print("Func is_in_range")
	#print("	Allowed range: ", range)
	var user_coords = Vector2i(user.data.tile_x, user.data.tile_y)
	var target_coords = Vector2i(target.data.tile_x, target.data.tile_y)

	var dx = abs(user_coords.x - target_coords.x)
	var dy = abs(user_coords.y - target_coords.y)
	
	var result = floor(sqrt(dx * dx + dy * dy))
	#print("Range: ", result)
	return result <= range
	
func has_line_of_sight(origin_char, target_char):
	var vm = Global.world_manager
	var origin = vm.get_char_coords(origin_char)
	var target = vm.get_char_coords(target_char)
	return line_of_sight_exists(origin.vec3.x, origin.vec3.y, origin.vec3.z, target.vec3.x, target.vec3.y, target.vec3.z)

func bresenham_line_3d(x1: int, y1: int, z1: int, x2: int, y2: int, z2: int) -> Array:
	var points := []

	var dx = abs(x2 - x1)
	var dy = abs(y2 - y1)
	var dz = abs(z2 - z1)

	var xs := 1 if x2 > x1 else -1
	var ys := 1 if y2 > y1 else -1
	var zs := 1 if z2 > z1 else -1

	if dx >= dy and dx >= dz:
		var p1 = 2 * dy - dx
		var p2 = 2 * dz - dx
		while x1 != x2:
			points.append(Vector3i(x1, y1, z1))
			x1 += xs
			if p1 >= 0:
				y1 += ys
				p1 -= 2 * dx
			if p2 >= 0:
				z1 += zs
				p2 -= 2 * dx
			p1 += 2 * dy
			p2 += 2 * dz

	elif dy >= dx and dy >= dz:
		var p1 = 2 * dx - dy
		var p2 = 2 * dz - dy
		while y1 != y2:
			points.append(Vector3i(x1, y1, z1))
			y1 += ys
			if p1 >= 0:
				x1 += xs
				p1 -= 2 * dy
			if p2 >= 0:
				z1 += zs
				p2 -= 2 * dy
			p1 += 2 * dx
			p2 += 2 * dz

	else:
		var p1 = 2 * dy - dz
		var p2 = 2 * dx - dz
		while z1 != z2:
			points.append(Vector3i(x1, y1, z1))
			z1 += zs
			if p1 >= 0:
				y1 += ys
				p1 -= 2 * dz
			if p2 >= 0:
				x1 += xs
				p2 -= 2 * dz
			p1 += 2 * dy
			p2 += 2 * dx

	points.append(Vector3i(x2, y2, z2))
	return points

func get_tile_data(x: int, y: int, z: int):
	var vm = Global.world_manager
	var layer = vm.layers.get(z)
	if not layer:
		return null
	var tile_map: TileMapLayer = layer["tile_map"]
	return tile_map.get_cell_tile_data(Vector2i(x, y))

func line_of_sight_exists(x1: int, y1: int, z1: int, x2: int, y2: int, z2: int) -> bool:
	var points = bresenham_line_3d(x1, y1, z1, x2, y2, z2)
	for i in range(1, points.size() - 1): # Skip endpoints
		var current = points[i]
		var previous = points[i - 1]

		var x = current.x
		var y = current.y
		var z = current.z
		var prev_z = previous.z

		var tile = get_tile_data(x, y, z)
		var tile_prev = get_tile_data(x, y, prev_z)

		if z != prev_z:
			# We're moving vertically — check if the space we're moving from is open
			if tile_prev == null or tile_prev.get_custom_data("floor") == true:
				return false
		else:
			# Horizontal — check passability
			if tile == null or tile.get_custom_data("passable") == false:
				return false

	return true

func roll_hostile_activity(user: Creature, user_stat: String, target: Creature, target_stat: String):
	var user_roll = randi_range(1, 12) 
	var user_score = user_roll + user.data.get(user_stat)
	var target_roll = randi_range(1, 12)
	var target_score = target_roll + target.data.get(target_stat)
	var contest_result = user_score - target_score
	print("contest_result: ", contest_result)
	var degree_of_success = determine_degree_success(contest_result)
	print("degree of success: ", degree_of_success)

	return degree_of_success

func enough_action_points_for_activity(activity):
	var cost = activity.AP_cost
	var char = Global.focus_char

	if char.data.current_ap < cost:
		print("Not enough action points.")
		SignalBus.dialog_show_message.emit("You don't have enough action points!")
		return false
	char.data.current_ap -= cost
	return true

func enough_action_points(cost):
	var char = Global.focus_char

	if char.data.current_ap < cost:
		print("Not enough action points.")
		SignalBus.dialog_show_message.emit("You don't have enough action points!")
		return false
	char.data.current_ap -= cost
	return true

func _on_weapon_attack(target):
	if not crisis_mode:
		SignalBus.dialog_show_message.emit("You are not in crisis mode!")
		return

	var ad = ActivityData.new(Global.focus_char, target, true)
	ad.user_stat = "offence"
	ad.target_stat = "melee_defence"
	ad.resistance = "physical_resistance"
	var activity = Library.get_activity("weapon_attack")
	activity.attach_data(ad)

	if activity is not WeaponAttack:
		return
	if activity.can_execute(Global.focus_char):
		activity.execute(Global.focus_char)
	SignalBus.update_ui_for_char.emit()

func _ready() -> void:
	SignalBus.start_crisis_mode.connect(start_crisis)
	SignalBus.end_crisis_mode.connect(end_crisis)
	SignalBus.end_crisis_turn.connect(end_turn)
	SignalBus.toggle_crisis_mode.connect(toggle_crisis)
	SignalBus.weapon_attack.connect(_on_weapon_attack)
