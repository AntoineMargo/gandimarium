@tool
extends EditorScript

func _run():
	var root = EditorInterface.get_edited_scene_root()
	if not root:
		push_error("No scene open!")
		return

	var next: int = 0

	var props = _get_all_props(root)

	for prop in props:
		if prop.uid < 0:
			prop.uid = next
			next += 1

	print("Assigned designer UIDs up to: ", next - 1)
	EditorInterface.save_scene()

func _get_all_props(node: Node) -> Array:
	var result = []
	for child in node.get_children():
		if child is Prop:
			result.append(child)
		# recurse into children
		result += _get_all_props(child)
	return result
