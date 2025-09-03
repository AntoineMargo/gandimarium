extends Node2D

class_name SelectionHighlight

var target = null
var highlight_color: Color = Color.GREEN

func _draw():
	var rect = Rect2(Vector2.ZERO, Vector2(Global.TILE_SIZE, Global.TILE_SIZE))
	draw_rect(rect, highlight_color, false, 1)

func set_tile_position(tile_coords: Vector2i):
	position = tile_coords * Global.TILE_SIZE

func update_selection_highlight():
	target = Global.focus_char
	var wm = Global.world_manager
	
	var tile_pos: Vector2i
	
	if target is Creature:
		if target.char_data.map_layer_id != wm.current_level:
			self.visible = false
			return
		tile_pos = Vector2i(target.char_data.tile_x, target.char_data.tile_y)
	elif target is Vector3i:
		if target.z != wm.current_level:
			self.visible = false
			return
		tile_pos = Vector2i(target.x, target.y)
	else:
		self.visible = false
		return

	self.set_tile_position(tile_pos)
	self.visible = true
	self.queue_redraw()

func _ready():
	z_index = 1000
