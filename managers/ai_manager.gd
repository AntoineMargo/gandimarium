extends Node
class_name AIManager

var wm = null
var nm = null

var active_creatures := {}
var active_number : int = 0

func sight_check(origin: Vector3i):
	for creature in Global.world_manager.current_world.creatures:
		if creature.data.player_controlled == false and creature.data.state == Enums.State.CONSCIOUS:
			var creature_coords = creature.get_coords()
			if WorldMath.pos_in_range_weighted_3d(creature_coords, origin, 40): # Fast check to make sure we're in the same general area
				if creature.sight_check(origin):
					var potential_creature = wm.get_creature_at_pos(origin)
					creature.discover_creature(potential_creature)
					creature.evaluate_entering_crisis(potential_creature)
					SignalBus.stop_all_movement.emit()

func noise_check(origin: Vector3i, strength: int):
	for creature in Global.world_manager.current_world.creatures:
		if creature.data.player_controlled == false and creature.data.state == Enums.State.CONSCIOUS:
			var creature_coords = creature.get_coords()
			if WorldMath.pos_in_range_weighted_3d(creature_coords, origin, 20): # Fast check to make sure we're in the same general area
				var noise_path_cost = nm.check_path_to_noise(origin, creature_coords)
				if creature.hearing_check(strength, noise_path_cost):
					var potential_creature = wm.get_creature_at_pos(origin)
					creature.discover_creature(potential_creature)
					creature.evaluate_entering_crisis(potential_creature)
					SignalBus.stop_all_movement.emit()

func regular_sight_checks():
	for creature in Global.world_manager.current_world.creatures:
		if creature.data.player_controlled == true:
			sight_check(creature.get_coords())

func move_hearing_checks():
	for creature in Global.world_manager.current_world.creatures:
		if creature.data.player_controlled == true and creature.mover.active:
			noise_check(creature.get_coords(), 5)

func regular_checks(_days, _hours, _minutes, _seconds):
	if Global.crisis_manager.crisis_mode:
		return
	regular_sight_checks()
	move_hearing_checks()
	
func delayed_check_setup():
	SignalBus.time_changed.connect(regular_checks)

func ai_became_active(creature):
	if active_creatures.has(creature):
		return
	SignalBus.dialog_show_message.emit("A creature's AI just turned active!")
	active_creatures[creature] = true
	active_number += 1
	#SignalBus.dialog_show_message.emit("1 more active creature: %d" % active_number)
	
func ai_became_inactive(creature):
	SignalBus.dialog_show_message.emit("A creature's AI just turned inactive.")
	active_creatures.erase(creature)
	active_number -= 1
	#SignalBus.dialog_show_message.emit("1 less active creature: %d" % active_number)

func _ready() -> void:
		SignalBus.world_ready.connect(delayed_check_setup)
		SignalBus.sight_check.connect(sight_check)
		SignalBus.ai_became_active.connect(ai_became_active)
		SignalBus.ai_became_inactive.connect(ai_became_inactive)
		wm = Global.world_manager
		nm = Global.noise_manager
