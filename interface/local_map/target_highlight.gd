extends Node2D
class_name TargetHighlight

var target = null
var highlight_color: Color = Color.YELLOW

func _draw():
	var rect = Rect2(Vector2.ZERO, Vector2(Global.TILE_SIZE, Global.TILE_SIZE))
	draw_rect(rect, highlight_color, false, 2)

func set_tile_position(tile_coords: Vector2i):
	position = tile_coords * Global.TILE_SIZE

func update_selection_highlight():
	var wm = Global.world_manager
	
	var tile_pos: Vector2i
	
	if target is Creature:
		if target.data.tile_z != wm.current_level:
			self.visible = false
			return
		tile_pos = Vector2i(target.data.tile_x, target.data.tile_y)
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
