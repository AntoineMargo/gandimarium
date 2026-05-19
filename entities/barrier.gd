extends Resource
class_name Barrier

@export var priority: int = 1
@export var direction: Enums.BarrierDirection =  Enums.BarrierDirection.INBOUND
@export var durability: int = 1
@export var durability_type: Enums.BarrierDurabilityType = Enums.BarrierDurabilityType.HP_BLOCKING

var parent_creature: Entity
var parent_condition: Condition

var original_target: Entity = null

func verify_compatibility(ctx: ActivityContext) -> bool:
	if ctx.activity.barrier_interaction == Enums.BarrierInteraction.STOP:
		if direction == Enums.BarrierDirection.BOTH:
			return true
		if ctx.target == parent_creature:
			if direction == Enums.BarrierDirection.INBOUND:
				return true
		elif ctx.user == parent_creature:
			if direction == Enums.BarrierDirection.OUTBOUND:
				return true
	return false
	
func handle_activity(ctx: ActivityContext) -> bool:
	original_target = null
	if verify_compatibility(ctx):
		original_target = ctx.target
		ctx.target = self
		return true
	else:
		return false

func take_damage(damage: int, resistance: Enums.Resistance):
	var final_damage = damage
	if final_damage <= 0:
		final_damage = 0
		return
	else:
		if durability_type == Enums.BarrierDurabilityType.CHARGES:
			durability -= 1
			SignalBus.dialog_show_message.emit("%s absorbed %d damage for %s!" % [parent_condition.name, final_damage, original_target.data.name])
		else:
			durability -= final_damage
			var remaining_damage: int = abs(final_damage)
			if durability <= 0:
				SignalBus.dialog_show_message.emit("%s took %d damage instead of %s!" % [parent_condition.name, (final_damage - remaining_damage), original_target.data.name])
				if durability_type == Enums.BarrierDurabilityType.HP_NON_BLOCKING:
					original_target.take_damage(remaining_damage, resistance)
			else:
				SignalBus.dialog_show_message.emit("%s took %d damage instead of %s!" % [parent_condition.name, final_damage, original_target.data.name])
	if durability <= 0:
		parent_condition.dispose()

#func setup -> void:
	#pass
