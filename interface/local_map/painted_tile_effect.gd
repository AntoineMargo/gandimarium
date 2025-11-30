extends ColorRect

func _ready():
	custom_minimum_size = Vector2(Global.TILE_SIZE, Global.TILE_SIZE)
	size = Vector2(Global.TILE_SIZE, Global.TILE_SIZE)
	position = Vector2(position.x - Global.TILE_SIZE/2, position.y - Global.TILE_SIZE/2)
	z_index = 999
