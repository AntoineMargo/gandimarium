extends Node2D

func setup(condition: AreaCondition):
	var wm = Global.world_manager
	var tiles = condition.affected_tiles

	var mm: MultiMesh = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_2D
	mm.instance_count = tiles.size()

	for i in range(tiles.size()):
		var pos = wm.tile_to_pixels(tiles[i])
		var xform: Transform2D = Transform2D()
		xform.origin = pos
		mm.set_instance_transform_2d(i, xform)

	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(Global.TILE_SIZE, Global.TILE_SIZE)
	mm.mesh = quad

	$MultiMeshInstance2D.multimesh = mm
	$MultiMeshInstance2D.z_index = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
