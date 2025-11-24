extends Effect
class_name ConsumeAPEffect

func apply(source, target, degree: int) -> void:
	if not target:
		return

	target.data.consume_ap(source.AP_cost)
