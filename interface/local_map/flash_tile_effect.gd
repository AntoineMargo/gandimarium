extends Node2D

@onready var colour_rect: ColorRect = get_node_or_null("ColorRect")

func _ready():
	z_index = 50
	$ColorRect.custom_minimum_size = Vector2(Global.TILE_SIZE, Global.TILE_SIZE)
	$ColorRect.size = Vector2(Global.TILE_SIZE, Global.TILE_SIZE)
	#$ColorRect.color = Color(1.0, 0.0, 0.0, 1.0)
	@warning_ignore("integer_division")
	$ColorRect.position = Vector2(-(Global.TILE_SIZE / 2), -(Global.TILE_SIZE / 2))
