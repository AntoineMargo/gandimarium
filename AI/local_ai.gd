extends Node
class_name LocalAI

var wm = null
var creature: Creature = null

var routine: LocalRoutine = null

func get_random_tile_in_zone(zone_rect: Rect2i) -> Vector2i:
	var x := randi_range(zone_rect.position.x, zone_rect.position.x + zone_rect.size.x - 1)
	var y := randi_range(zone_rect.position.y, zone_rect.position.y + zone_rect.size.y - 1)
	return Vector2i(x, y)

func perform_routine():
	var time: Vector4i = Global.time_manager.get_time()
	var current_entry = routine.get_current_entry(time[1])
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
	var chosen_zone = valid_zones.pick_random()

	var layer_coords: Vector2i = get_random_tile_in_zone(chosen_zone.rect)
	var coords = Vector3i(layer_coords.x, layer_coords.y, fav_level)
	wm.interact_move(creature, coords)

func _ready() -> void:
	creature = $"../.."
	wm = Global.world_manager
	#SignalBus.local_turn_passed.connect(perform_routine)
