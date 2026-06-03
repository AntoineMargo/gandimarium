extends Modifier
class_name EffectModifier

enum TargetedArray {
	SELF_PRIOR,
	SELF_PER_TARGET,
	SELF_FINAL,
	TARGET
}
@export var targeted_array: TargetedArray = TargetedArray.TARGET
@export var effects_to_append: Array[Effect]

func modify(act: Activity):
	for effect in effects_to_append:
		match targeted_array:
			TargetedArray.SELF_PRIOR:
				act.self_prior_effects.append(effect)
			TargetedArray.SELF_PER_TARGET:
				act.self_per_target_effects.append(effect)
			TargetedArray.SELF_FINAL:
				act.self_final_effects.append(effect)
			TargetedArray.TARGET:
				act.target_effects.append(effect)

#func modify(ctx: ActivityContext):
	#var activity = ctx.activity
	#for effect in effects_to_append:
		#match TargetedArray:
			#TargetedArray.SELF_PRIOR:
				#activity.self_prior_effects.append(effect)
			#TargetedArray.SELF_PER_TARGET:
				#activity.self_per_target_effects.append(effect)
			#TargetedArray.SELF_FINAL:
				#activity.self_final_effects.append(effect)
			#TargetedArray.TARGET:
				#activity.target_effects.append(effect)
