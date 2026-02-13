@tool
extends EditorInspectorPlugin

func _can_handle(object):
	return object is ZonePainter

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if name == "zones":
		# For now, just use the default array editor
		# The zones can be edited directly in the inspector
		return false
	return false
