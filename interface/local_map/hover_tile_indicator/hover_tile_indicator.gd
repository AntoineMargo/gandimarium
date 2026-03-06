extends Node2D

@export var tile_size = Global.TILE_SIZE

func set_tile(tile: Vector3i) -> void:
	position = Vector2(tile.x, tile.y) * tile_size
	queue_redraw()

func _draw() -> void:
	var rect = Rect2(Vector2.ZERO, Vector2(tile_size, tile_size))
	draw_rect(rect, Color8(255, 255, 255, 180), false, 0.5)
