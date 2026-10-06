extends Node2D
class_name SelectionHighlight

var target = null
var highlight_color: Color = Color.GREEN

func _draw():
	var rect = Rect2(Vector2.ZERO, Vector2(Global.TILE_SIZE, Global.TILE_SIZE))
	draw_rect(rect, highlight_color, false, 1)


func update_selection_highlight():
	target = Global.focus_char
	var wm = Global.game_session.world_manager

	if not target:
		visible = false
		return

	if wm.current_map.id == target.data.map_id and wm.current_layer == target.data.tile_z:
		visible = true
	else:
		visible = false
		return

	# World-space follow
	global_position = Vector2(target.mover.global_position.x - Global.TILE_SIZE * 0.5, 
		target.mover.global_position.y - Global.TILE_SIZE * 0.5)
	visible = true
	queue_redraw()


func _ready():
	z_index = 1000
