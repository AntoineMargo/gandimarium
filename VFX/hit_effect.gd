extends Node2D

@export var colour: Color = Color(0.957, 0.459, 0.212, 1.0)

var context: ActivityContext

func configure(config: Dictionary) -> void:
	if config.has("colour"):
		colour = config["colour"]

func apply() -> void:
	var wm = Global.world_manager
	#var centre_tile = context.target
	
	var tiles: Array[Vector3i] = context.affected_tiles
	for tile in tiles:
		var layer_tile: Vector2i = Vector2i(tile.x, tile.y)
		wm.flash_tile_overlay(layer_tile, colour)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	apply()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
