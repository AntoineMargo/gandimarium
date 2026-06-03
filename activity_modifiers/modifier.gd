@abstract
extends Resource
class_name Modifier

@export var name: String = ""
@export var id: String = ""

@export var tags: Array[Enums.Tag] = []
@export var filters: Array[Filter] = []

var owner: Entity = null

func applies(ctx: Context) -> bool:
	if ctx is ActivityContext:
		var activity = ctx.activity
		if tags:
			for tag in tags:
				if not activity.has_tag(tag):
					return false
	if filters:
		for filter in filters:
			if not filter.is_satisfied(ctx):
				return false
	
	return true

func destroy() -> void:
	if owner and owner.has_method("remove_activity_modifier"):
			owner.remove_activity_modifier(self)
