extends ProgressBar

func _ready() -> void:
	size = Vector2(Global.TILE_SIZE, 2)
	position = Vector2(-Global.TILE_SIZE / 2, Global.TILE_SIZE / 2 + 1)
