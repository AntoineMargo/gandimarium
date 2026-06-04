extends Node2D

func setup(creature: Entity) -> void:
	var overlay = Sprite2D.new()
	overlay.texture = creature.sprite_node.texture
	overlay.hframes = creature.sprite_node.hframes
	overlay.vframes = creature.sprite_node.vframes
	overlay.frame = creature.sprite_node.frame

	#overlay.modulate = Color.WHITE
	overlay.modulate = Color(0.225, 0.1, 0.678, 0.757)
	self.add_child(overlay)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
