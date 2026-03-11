extends Node
class_name AIManager

var active_creatures := {}
var active_number : int = 0

func noticing_check(origin: Vector3i):
	var wm = Global.world_manager
	for creature in Global.world_manager.current_world.creatures:
		if creature.data.player_controlled == false and creature.data.state == Enums.State.CONSCIOUS:
			var self_coords = Global.world_manager.get_char_coords(creature)
			if WorldMath.pos_in_range_weighted_3d(self_coords.vec3, origin, 40):
				if creature.senses_check_on_tile(origin):
					var potential_creature = wm.find_creature_on_tile(origin)
					creature.discover_creature(potential_creature)
					creature.evaluate_entering_crisis(potential_creature)
					SignalBus.stop_all_movement.emit()

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
		SignalBus.noticing_check.connect(noticing_check)
		SignalBus.ai_became_active.connect(ai_became_active)
		SignalBus.ai_became_inactive.connect(ai_became_inactive)
