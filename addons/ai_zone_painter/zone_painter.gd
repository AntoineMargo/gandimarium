@tool
extends Node2D
class_name ZonePainter

## Visual editor tool for drawing zone rectangles on tilemaps
## Add this as a child of your TileMap node and use the editor to draw zones

@export var zones: Array[ZoneData] = []
@export var tile_size: Vector2i = Vector2i(16, 16)  # Adjust to match your tilemap
@export var draw_color: Color = Color(0.2, 0.6, 1.0, 0.3)
@export var border_color: Color = Color(0.2, 0.6, 1.0, 0.8)
@export var selected_color: Color = Color(1.0, 0.8, 0.2, 0.4)

# Internal state (managed by plugin)
var is_drawing: bool = false
var draw_start: Vector2i
var draw_end: Vector2i
var selected_zone_index: int = -1
var hover_zone_index: int = -1

func _ready():
	if Engine.is_editor_hint():
		queue_redraw()

func get_zone_at_position(tile_pos: Vector2i) -> int:
	for i in range(zones.size() - 1, -1, -1):  # Check from top to bottom
		if zones[i].rect.has_point(tile_pos):
			return i
	return -1

func create_zone_from_rect():
	var min_x = min(draw_start.x, draw_end.x)
	var min_y = min(draw_start.y, draw_end.y)
	var max_x = max(draw_start.x, draw_end.x)
	var max_y = max(draw_start.y, draw_end.y)
	
	var new_zone = ZoneData.new()
	new_zone.rect = Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)
	new_zone.capacity = new_zone.rect.get_area()
	
	zones.append(new_zone)
	selected_zone_index = zones.size() - 1
	notify_property_list_changed()

func _draw():
	if not Engine.is_editor_hint():
		return
	
	# Draw existing zones
	for i in range(zones.size()):
		var zone = zones[i]
		var color = draw_color
		var border = border_color
		
		if i == selected_zone_index:
			color = selected_color
			border = Color(1.0, 0.8, 0.2, 1.0)
		elif i == hover_zone_index:
			color = Color(draw_color.r, draw_color.g, draw_color.b, draw_color.a * 1.5)
		
		draw_zone_rect(zone.rect, color, border)
		
		# Draw zone info text
		var text_pos = Vector2(zone.rect.position.x * tile_size.x, zone.rect.position.y * tile_size.y - 5)
		var info_text = "Zone %d" % i
		if zone.tags.size() > 0:
			info_text += " [%s]" % ", ".join(zone.tags)
		draw_string(ThemeDB.fallback_font, text_pos, info_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, border)
		
		# Draw detailed info for selected zone
		if i == selected_zone_index:
			var detail_pos = Vector2(zone.rect.position.x * tile_size.x, (zone.rect.position.y + zone.rect.size.y) * tile_size.y + 15)
			var details = "Priority: %.1f | Capacity: %d | Size: %dx%d" % [
				zone.priority,
				zone.capacity,
				zone.rect.size.x,
				zone.rect.size.y
			]
			# Draw background for readability
			var text_size = ThemeDB.fallback_font.get_string_size(details, HORIZONTAL_ALIGNMENT_LEFT, -1, 12)
			draw_rect(Rect2(detail_pos - Vector2(2, 12), text_size + Vector2(4, 2)), Color(0, 0, 0, 0.7))
			draw_string(ThemeDB.fallback_font, detail_pos, details, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1, 1, 1, 1))
	
	# Draw current drawing rectangle
	if is_drawing:
		var min_x = min(draw_start.x, draw_end.x)
		var min_y = min(draw_start.y, draw_end.y)
		var max_x = max(draw_start.x, draw_end.x)
		var max_y = max(draw_start.y, draw_end.y)
		
		var temp_rect = Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)
		draw_zone_rect(temp_rect, Color(1.0, 1.0, 1.0, 0.3), Color(1.0, 1.0, 1.0, 0.8))

func draw_zone_rect(rect: Rect2i, fill_color: Color, border_color: Color):
	# Convert tile rect to pixel rect
	var pixel_rect = Rect2(
		rect.position.x * tile_size.x,
		rect.position.y * tile_size.y,
		rect.size.x * tile_size.x,
		rect.size.y * tile_size.y
	)
	
	# Draw filled rectangle
	draw_rect(pixel_rect, fill_color)
	
	# Draw border
	draw_rect(pixel_rect, border_color, false, 2.0)

func _process(_delta):
	if Engine.is_editor_hint():
		queue_redraw()

# Helper functions for runtime use
func find_zones_with_tag(tag: String) -> Array[ZoneData]:
	var results: Array[ZoneData] = []
	for zone in zones:
		if tag in zone.tags:
			results.append(zone)
	return results

func get_zone_center_world(zone: ZoneData) -> Vector2:
	var center_tile = zone.rect.position + zone.rect.size / 2
	return Vector2(center_tile) * Vector2(tile_size.x, tile_size.y)

func get_random_point_in_zone(zone: ZoneData) -> Vector2i:
	var x = zone.rect.position.x + randi() % zone.rect.size.x
	var y = zone.rect.position.y + randi() % zone.rect.size.y
	return Vector2i(x, y)

# Helper function to export zones to a file
func save_zones_to_file(path: String):
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		for zone in zones:
			file.store_var(zone)
		file.close()
		print("Zones saved to: ", path)

# Helper function to load zones from a file
func load_zones_from_file(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		zones.clear()
		while file.get_position() < file.get_length():
			var zone = file.get_var()
			if zone is ZoneData:
				zones.append(zone)
		file.close()
		queue_redraw()
		notify_property_list_changed()
		print("Zones loaded from: ", path)
