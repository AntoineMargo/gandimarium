@tool
extends EditorPlugin

var inspector_plugin  # No type annotation to avoid Godot type checker issues
var current_zone_painter: ZonePainter = null
var canvas_item_editor: Control = null
var is_drawing: bool = false
var is_dragging: bool = false
var drag_zone_index: int = -1
var drag_offset: Vector2i = Vector2i.ZERO
var draw_start: Vector2i
var draw_end: Vector2i
var selected_zone_index: int = -1

func _enable_plugin() -> void:
	print("Zone Painter Plugin Enabled!")
	print("Usage:")
	print("  1. Add ZonePainter as child of your TileMap")
	print("  2. Select the ZonePainter node")
	print("  3. Left-click and drag in viewport to draw zones")
	print("  4. Right-click to delete zones")
	print("  5. Press Delete key to remove selected zone")
	print("  6. Edit zone properties in the inspector")

func _disable_plugin() -> void:
	print("Zone Painter Plugin Disabled")
	current_zone_painter = null
	canvas_item_editor = null

func _enter_tree() -> void:
	# Load and instantiate the inspector plugin
	var InspectorPluginScript = load("res://addons/ai_zone_painter/zone_painter_inspector_plugin.gd")
	if InspectorPluginScript:
		inspector_plugin = InspectorPluginScript.new()
		if inspector_plugin:
			add_inspector_plugin(inspector_plugin)
		else:
			push_error("Zone Painter: Failed to instantiate inspector plugin")
	else:
		push_error("Zone Painter: Failed to load inspector plugin script")

func _exit_tree() -> void:
	if inspector_plugin:
		remove_inspector_plugin(inspector_plugin)
	current_zone_painter = null
	canvas_item_editor = null

func _handles(object) -> bool:
	return object is ZonePainter

func _edit(object) -> void:
	current_zone_painter = object as ZonePainter
	if current_zone_painter:
		current_zone_painter.queue_redraw()

func _make_visible(visible: bool) -> void:
	if not visible:
		current_zone_painter = null

func _forward_canvas_gui_input(event: InputEvent) -> bool:
	if not current_zone_painter:
		return false
	
	# Get the transform from the 2D viewport
	var canvas_transform = current_zone_painter.get_viewport_transform()
	
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		# Convert viewport position to world position
		var world_pos = canvas_transform.affine_inverse() * mouse_event.position
		
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_event.pressed:
				var tile_pos = world_to_tile(world_pos)
				var clicked_zone = current_zone_painter.get_zone_at_position(tile_pos)
				
				if clicked_zone >= 0:
					selected_zone_index = clicked_zone
					current_zone_painter.selected_zone_index = clicked_zone
					current_zone_painter.queue_redraw()
					# Update the inspector to show this zone's properties
					current_zone_painter.notify_property_list_changed()
					# Print which zone was selected for user feedback
					print("Selected Zone %d - Rect: %s, Tags: %s" % [
						clicked_zone, 
						current_zone_painter.zones[clicked_zone].rect,
						current_zone_painter.zones[clicked_zone].tags
					])
				else:
					is_drawing = true
					draw_start = tile_pos
					draw_end = tile_pos
					selected_zone_index = -1
					current_zone_painter.selected_zone_index = -1
					current_zone_painter.is_drawing = true
					current_zone_painter.draw_start = draw_start
					current_zone_painter.draw_end = draw_end
				return true
			else:
				if is_drawing:
					is_drawing = false
					current_zone_painter.is_drawing = false
					current_zone_painter.create_zone_from_rect()
					current_zone_painter.queue_redraw()
					return true
		
		elif mouse_event.button_index == MOUSE_BUTTON_RIGHT:
			if mouse_event.pressed:
				# Start dragging a zone
				var tile_pos = world_to_tile(world_pos)
				var zone_index = current_zone_painter.get_zone_at_position(tile_pos)
				if zone_index >= 0:
					is_dragging = true
					drag_zone_index = zone_index
					# Calculate offset from zone's top-left corner to click position
					drag_offset = tile_pos - current_zone_painter.zones[zone_index].rect.position
					selected_zone_index = zone_index
					current_zone_painter.selected_zone_index = zone_index
					current_zone_painter.queue_redraw()
					return true
			else:
				# Stop dragging
				if is_dragging:
					is_dragging = false
					drag_zone_index = -1
					current_zone_painter.notify_property_list_changed()
					return true
	
	elif event is InputEventMouseMotion:
		var world_pos = canvas_transform.affine_inverse() * event.position
		if is_drawing:
			draw_end = world_to_tile(world_pos)
			current_zone_painter.draw_end = draw_end
			current_zone_painter.queue_redraw()
			return true
		elif is_dragging and drag_zone_index >= 0:
			# Move the zone
			var tile_pos = world_to_tile(world_pos)
			var new_position = tile_pos - drag_offset
			current_zone_painter.zones[drag_zone_index].rect.position = new_position
			current_zone_painter.queue_redraw()
			return true
		else:
			var tile_pos = world_to_tile(world_pos)
			var new_hover = current_zone_painter.get_zone_at_position(tile_pos)
			if new_hover != current_zone_painter.hover_zone_index:
				current_zone_painter.hover_zone_index = new_hover
				current_zone_painter.queue_redraw()
	
	elif event is InputEventKey:
		if event.pressed and event.keycode == KEY_DELETE:
			if selected_zone_index >= 0 and selected_zone_index < current_zone_painter.zones.size():
				current_zone_painter.zones.remove_at(selected_zone_index)
				selected_zone_index = -1
				current_zone_painter.selected_zone_index = -1
				current_zone_painter.queue_redraw()
				current_zone_painter.notify_property_list_changed()
				return true
	
	return false

func world_to_tile(world_pos: Vector2) -> Vector2i:
	# Convert world position to local position relative to ZonePainter
	var local_pos = current_zone_painter.to_local(world_pos)
	# Convert local position to tile coordinates
	return Vector2i(
		int(floor(local_pos.x / current_zone_painter.tile_size.x)),
		int(floor(local_pos.y / current_zone_painter.tile_size.y))
	)

func _forward_canvas_draw_over_viewport(viewport_control: Control) -> void:
	if current_zone_painter:
		current_zone_painter.queue_redraw()
