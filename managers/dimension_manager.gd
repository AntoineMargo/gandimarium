extends Node
class_name DimensionManager

const DIMENSION_SPACING: int = 1000

var dimensions: Dictionary[int, DimensionData] = {}
var next_dimension_index: int = 1


func offset_layers(element: Node, offset: int) -> void:
	for child in element.get_children():
		if child is TileMapLayer:
			var child_id = child.get("id")
			if child_id:
				child.id += offset
		offset_layers(child, offset)

func create_dimension(dimension: PackedScene) -> DimensionData:
	var new_dimension_data: DimensionData = DimensionData.new()

	new_dimension_data.id = next_dimension_index
	new_dimension_data.base_z = next_dimension_index * DIMENSION_SPACING

	var dimension_instance: Node = dimension.instantiate()
	offset_layers(dimension_instance, new_dimension_data.base_z)

	Global.world_manager.current_world.add_child(dimension_instance)
	new_dimension_data.root_node = dimension_instance

	dimensions[next_dimension_index] = new_dimension_data
	next_dimension_index += 1

	return new_dimension_data


func remove_dimension(dimension_id: int) -> void:
	var dimension: DimensionData = dimensions.get(dimension_id)
	if dimension == null:
		return

	Global.world_manager.remove_dimension_layers(dimension.base_z, dimension.base_z + 1000)

	dimension.root_node.free()

	dimensions.erase(dimension_id)


func _ready() -> void:
	pass # Replace with function body.
