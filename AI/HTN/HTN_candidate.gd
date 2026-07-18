extends Resource
class_name HTNCandidate
## If left "null" (empty), defaults to regular movement.

@export var activity_variant: ActivityVariant

func _init(p_activity_variant: ActivityVariant = null) -> void:
	activity_variant = p_activity_variant
	
#func get_candidate():
	#
