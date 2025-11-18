extends Node

func _ready():
	var d = DamagePattern.new()  # Must be a Resource
	var path = "res://items/misc/damage_pattern_clean.tres"
	var err = ResourceSaver.save(d, path)  # Resource first, path second
	if err != OK:
		print("Failed to save resource:", err)
	else:
		print("Resource saved successfully at", path)

	var r = ResourceLoader.load(path)
	print("Loaded resource:", r, "class:", r.get_class())
