extends Node

func _ready():
	Global.game_root = self
	load_map("res://locations/test_location_2/region.tscn")
	Global.current_camera = $Camera2D
	if not is_instance_valid(Global.world_manager.selection_highlight):
		Global.world_manager.selection_highlight = preload("res://interface/selection_highlight.tscn").instantiate()
	self.add_child(Global.world_manager.selection_highlight)

func load_map(path: String):
	var world_container = $WorldContainer
	
	for child in world_container.get_children():
		child.queue_free()

	var new_map_scene = load(path)
	var new_map = new_map_scene.instantiate()
	world_container.add_child(new_map)

	Global.world_manager.current_world = new_map
	#await get_tree().create_timer(0.1).timeout
	await get_tree().process_frame
	Global.world_manager.selection_highlight.update_selection_highlight()
