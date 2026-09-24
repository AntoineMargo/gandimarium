extends TriggerFilter
class_name ActivityAPCostFilter


enum Sign {
	OVER,
	OVER_OR_EQUAL,
	EQUAL,
	UNDER_OR_EQUAL,
	UNDER
}

## Activity AP cost should be over, equal or under the value.
@export var desired_sign: Sign = Sign.EQUAL
@export var value: int = 1


func is_satisfied(ctx: Context, _source: Entity = null) -> bool:
	if ctx is not ActivityContext:
		return false
	
	var activity: Activity = ctx.activity
	
	match desired_sign:
		Sign.OVER:
			if activity.AP_cost > value:
				return true
		Sign.OVER_OR_EQUAL:
			if activity.AP_cost >= value:
				return true
		Sign.EQUAL:
			if activity.AP_cost == value:
				return true
		Sign.UNDER_OR_EQUAL:
			if activity.AP_cost <= value:
				return true
		Sign.UNDER:
			if activity.AP_cost < value:
				return true

	return false
