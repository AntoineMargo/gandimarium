extends Modifier
class_name FilterModifier

enum TargetedArray {
	SELF,
	TARGET
}

@export var targeted_array: TargetedArray = TargetedArray.TARGET
@export var filters_to_append: Array[Filter]

func modify(ctx: ActivityContext):
	var activity = ctx.activity
	for filter in filters_to_append:
		match targeted_array:
			TargetedArray.SELF:
				activity.self_filters.append(filter)
			TargetedArray.TARGET:
				activity.target_filters.append(filter)

@warning_ignore("shadowed_variable")
func matches(value_type: Enums.ValueType, stage: Enums.ActivityStage) -> bool:
	return self.value_type == value_type and self.stage == stage
