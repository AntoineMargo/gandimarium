@abstract
extends Resource
class_name Modifier

@export var name: String = ""
@export var id: String = ""

@export var value_type: Enums.ValueType
@export var stage: Enums.ActivityStage
@export var tags: Array[String] = []
@export var filters: Array[Filter] = []

func modify(_value, _ctx: Context):
	pass

@warning_ignore("shadowed_variable")
func matches(value_type: Enums.ValueType, stage: Enums.ActivityStage) -> bool:
	return self.value_type == value_type and self.stage == stage

func applies(ctx: Context) -> bool:
	if tags:
		for tag in tags:
			if tag not in ctx.activity.tags:
				return false
	if filters:
		for filter in filters:
			if not filter.is_satisfied(ctx):
				return false
	
	return true
