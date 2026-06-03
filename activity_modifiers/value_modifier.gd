@abstract
extends Modifier
class_name ValueModifier

@export var value_type: Enums.ValueType
@export var stage: Enums.ActivityStage

func modify(_value, _ctx: Context):
	pass

@warning_ignore("shadowed_variable")
func matches(value_type: Enums.ValueType, stage: Enums.ActivityStage) -> bool:
	return self.value_type == value_type and self.stage == stage
