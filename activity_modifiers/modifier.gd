@abstract
extends Resource
class_name Modifier

@export var name: String = ""
@export var id: String = ""

@export var value_type: Enums.ValueType
@export var stage: Enums.ActivityStage
@export var tags: Array[Enums.Tag] = []
@export var filters: Array[Filter] = []

var owner: Entity = null

func modify(_value, _ctx: Context):
	pass

@warning_ignore("shadowed_variable")
func matches(value_type: Enums.ValueType, stage: Enums.ActivityStage) -> bool:
	return self.value_type == value_type and self.stage == stage

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
	#if owner and owner.has_method("remove_modifier"):
			#owner.remove_modifier(self)
