extends Node2D

class_name Creature

@export var char_data: CreatureData
@export var health_bar_scene: PackedScene

@onready var sprite_node = $Sprite2D

var health_bar_instance: Node

func update_world_position():
	if Global.current_tile_map_layer and char_data:
		var tile_pos = Vector2i(self.char_data.tile_x, self.char_data.tile_y)
		position = Global.current_tile_map_layer.map_to_local(tile_pos)

func _ready():
	char_data.creature = self
	if not health_bar_scene:
		print("Health bar scene not set!")
		return
	health_bar_instance = health_bar_scene.instantiate()
	add_child(health_bar_instance)
