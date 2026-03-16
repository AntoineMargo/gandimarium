extends Node
class_name LocalAI

var wm = null
var creature: Creature = null

var routine: LocalRoutine = null
var current_entry: RoutineEntry

var chosen_zones: Array[ZoneData]

func get_random_tile_in_zone(zone_rect: Rect2i) -> Vector2i:
	var x: int = randi_range(zone_rect.position.x, zone_rect.position.x + zone_rect.size.x - 1)
	var y: int = randi_range(zone_rect.position.y, zone_rect.position.y + zone_rect.size.y - 1)
	return Vector2i(x, y)

func perform_routine(override: Enums.Routine = Enums.Routine.NONE, tile: Vector3i = Vector3i(0, 0, 0)):
	if not current_entry:
		change_routine()
	if override != Enums.Routine.NONE:
		if override == Enums.Routine.CHECK_SOUND:
			check_sound_origin(tile)
	if creature.mover.active:
		return
	if current_entry.behaviour == "patrol":
		patrol()

func change_routine():
	var time: Vector4i = Global.time_manager.get_time()
	current_entry = routine.get_current_entry(time[1])
	var ai_zones =  Global.world_manager.ai_zones
	var valid_zones: Array[ZoneData] = []
	var fav_level: int = creature.data.tile_z
	if not ai_zones.has(fav_level):
		return
	for zone in ai_zones[fav_level]:
		if current_entry.location_tag in zone.tags:
			valid_zones.append(zone)
	if valid_zones.is_empty():
		return
	chosen_zones = valid_zones

func check_sound_origin(tile):
	wm.get_close_to_target(creature, tile, 1)

func patrol():
	if not chosen_zones:
		return
	var chosen_zone = chosen_zones.pick_random()
	var creature_coords: Vector3i = creature.get_coords()
	var layer_coords: Vector2i = Vector2i(0, 0)
	for i in range(3):
		var tentative_coords = get_random_tile_in_zone(chosen_zone.rect)
		if not wm.get_tile_occupied(Vector3i(tentative_coords.x, tentative_coords.y, creature_coords.z)):
			layer_coords = tentative_coords
			break
	if layer_coords == Vector2i(0, 0):
		layer_coords = Vector2i(creature_coords.x, creature_coords.y)
	wm.interact_move(creature, Vector3i(layer_coords.x, layer_coords.y, creature_coords.z))

func _ready() -> void:
	creature = $"../.."
	wm = Global.world_manager
	#SignalBus.time_changed.connect(perform_routine)
