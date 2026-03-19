extends Node2D

func _ready():
	z_index = 999
	$ColorRect.custom_minimum_size = Vector2(Global.TILE_SIZE, Global.TILE_SIZE)
	$ColorRect.size = Vector2(Global.TILE_SIZE, Global.TILE_SIZE)
	@warning_ignore("integer_division")
	$ColorRect.position = Vector2(-(Global.TILE_SIZE / 2), -(Global.TILE_SIZE / 2))
