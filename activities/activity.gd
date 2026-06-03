extends Resource
class_name Activity

@export var name: String = "placeholder"
@export var id: String = "placeholder"
@export var description: String = "This is a placeholder description."
@export var icon: String = "res://art/interface/activities/placeholder1.png"
@export var tags: Array[Enums.Tag] = []
@export var AP_cost: int = 1
@export var PP_cost: int = 0
@export var EP_cost: int = 0
@export var requires_concentration: bool = false
@export var reach_requires_LOS: bool = true
@export var spread_requires_LOS: bool = true
@export var attacking_aptitude: Enums.Aptitude = Enums.Aptitude.WILL
@export var defending_aptitude: Enums.Aptitude = Enums.Aptitude.WILL
@export var reach: int = 1
@export var spread: int = 0
@export var delay: int = 0

@export var modifiers: Array[Modifier] = []
@export var self_filters: Array[Filter] = []
@export var self_prior_effects: Array[Effect] = []
@export var self_per_target_effects: Array[Effect] = []
@export var self_final_effects: Array[Effect] = []

@export var target_filters: Array[Filter] = []
@export var target_effects: Array[Effect] = []
@export var targeting_type: Enums.Targeting = Enums.Targeting.ENTITIES
@export var affected_type: Enums.Affected = Enums.Affected.ENTITIES
@export var shape: Enums.Shape = Enums.Shape.BURST
@export var barrier_interaction: Enums.BarrierInteraction = Enums.BarrierInteraction.IGNORE
@export var can_only_hit_once: bool = true

@export var projectile: ProjVFXEffect = null
@export var projectile_batch_mode: bool = true

@export var requires_crisis: bool = false
@export var requires_roll: bool = true
@export var is_invisible: bool = false
@export var triggers_reaction: bool = true
@export var is_spell: bool = false
@export var toggleable: bool = false
@export var builds_condition: bool = false
@export var per_round_drain: bool = false
@export var condition_id: String = ""
@export var attack_types: Array[DamagePattern]
@export var ai_hint: AIHint

var user = null
var origin: Vector3i
var concentration: Concentration = null
var weapon: Item = null

var target_points: Array[Vector3i] = []
var target_entities: Array = []

var imported_context: ActivityContext = null

func _setup_concentration():
	if requires_concentration:
		concentration = Concentration.new()
		concentration.setup(self, per_round_drain)

func _finalize_concentration(_context: ActivityContext):
	if requires_concentration:
		if concentration.linked_conditions.size() > 0:
			user.add_concentration(concentration)
			concentration.finalize_setup()
			
		else:
			concentration.cancel()

func _build_shared_context():
	var shared_ctx = SharedContext.new()
	return shared_ctx

func _import_context():
	if imported_context:
		user = imported_context.user
		origin = imported_context.origin
		if imported_context.concentration:
			concentration = imported_context.concentration

func _build_context(shared_ctx: SharedContext = null, target = null, already_hit = null):
	var ctx = ActivityContext.new()
	if shared_ctx:
		ctx.shared_context = shared_ctx
	ctx.activity = self
	ctx.id = id
	ctx.user = user
	ctx.origin = user.get_coords()
	
	ctx.target = target
	
	ctx.already_hit = already_hit
	
	ctx.current_spell_rank = user.get_final_stat("current_spell_rank")
	ctx.concentration = concentration
	
	if ctx.target is Creature or ctx.target is Prop:
		ctx.tile_spawned_on = target.get_coords()
	
	ctx.user_stat = user.get_aptitude(attacking_aptitude)
	if ctx.target is Creature:
		ctx.target_stat = target.get_aptitude(defending_aptitude)
	else:
		ctx.target_stat = 0

	return ctx

func modify_value(value, value_type: Enums.ValueType, ctx: Context, stage: Enums.ActivityStage):
	for modifier in modifiers:
		if modifier is not ValueModifier:
			continue

		if not modifier.matches(value_type, stage):
			continue

		if not modifier.applies(ctx):
			continue

		value = modifier.modify(value, ctx)
	
	return value

func compute_spell_reach():
	if is_spell:
		var acuity = user.get_final_stat("acuity")
		reach *= acuity
		#reach = reach + acuity

func apply_effect_modifiers():
	for modifier in modifiers:
		if modifier is EffectModifier:
			modifier.modify(self)

func pre_execution_bundle_modify(ctx: Context):
	apply_effect_modifiers()

	AP_cost = modify_value(AP_cost, Enums.ValueType.AP_COST, ctx, Enums.ActivityStage.PRE_EXECUTION)
	PP_cost = modify_value(PP_cost, Enums.ValueType.PP_COST, ctx, Enums.ActivityStage.PRE_EXECUTION)
	EP_cost = modify_value(EP_cost, Enums.ValueType.EP_COST, ctx, Enums.ActivityStage.PRE_EXECUTION)
	
	attacking_aptitude = modify_value(attacking_aptitude, Enums.ValueType.ATTACKING_APTITUDE, ctx, Enums.ActivityStage.PRE_EXECUTION)
	defending_aptitude = modify_value(defending_aptitude, Enums.ValueType.DEFENDING_APTITUDE, ctx, Enums.ActivityStage.PRE_EXECUTION)
	
	reach = modify_value(reach, Enums.ValueType.REACH, ctx, Enums.ActivityStage.PRE_EXECUTION)
	spread = modify_value(spread, Enums.ValueType.SPREAD, ctx, Enums.ActivityStage.PRE_EXECUTION)
	delay = modify_value(delay, Enums.ValueType.DELAY, ctx, Enums.ActivityStage.PRE_EXECUTION)
	
	reach_requires_LOS = modify_value(reach_requires_LOS, Enums.ValueType.REACH_LOS, ctx, Enums.ActivityStage.PRE_EXECUTION)
	spread_requires_LOS = modify_value(spread_requires_LOS, Enums.ValueType.SPREAD_LOS, ctx, Enums.ActivityStage.PRE_EXECUTION)
	can_only_hit_once = modify_value(can_only_hit_once, Enums.ValueType.CAN_ONLY_HIT_ONCE, ctx, Enums.ActivityStage.PRE_EXECUTION)
	triggers_reaction = modify_value(triggers_reaction, Enums.ValueType.TRIGGERS_REACTION, ctx, Enums.ActivityStage.PRE_EXECUTION)
	
	shape = modify_value(shape, Enums.ValueType.SHAPE, ctx, Enums.ActivityStage.PRE_EXECUTION)
	origin = modify_value(origin, Enums.ValueType.ORIGIN, ctx, Enums.ActivityStage.PRE_EXECUTION)
	weapon = modify_value(weapon, Enums.ValueType.WEAPON, ctx, Enums.ActivityStage.PRE_EXECUTION)

func pre_roll_bundle_modify(ctx: ActivityContext):
	ctx.user_roll = modify_value(ctx.user_roll, Enums.ValueType.USER_ROLL, ctx, Enums.ActivityStage.PRE_ROLL)
	ctx.target_roll = modify_value(ctx.target_roll, Enums.ValueType.TARGET_ROLL, ctx, Enums.ActivityStage.PRE_ROLL)

func post_roll_bundle_modify(ctx: ActivityContext):
	ctx.user_roll = modify_value(ctx.user_roll, Enums.ValueType.USER_ROLL, ctx, Enums.ActivityStage.POST_ROLL)
	ctx.target_roll = modify_value(ctx.target_roll, Enums.ValueType.TARGET_ROLL, ctx, Enums.ActivityStage.POST_ROLL)

func post_resolution_bundle_modify(ctx: ActivityContext):
	ctx.result = modify_value(ctx.result, Enums.ValueType.RESULT_ROLL, ctx, Enums.ActivityStage.POST_RESOLUTION)
	ctx.degree = modify_value(ctx.degree, Enums.ValueType.DEGREE, ctx, Enums.ActivityStage.POST_RESOLUTION)

#func effect_bundle_modify(ctx: ActivityContext):
	#ctx.result = modify_value(ctx.result, Enums.ValueType.RESULT_ROLL, ctx, Enums.ActivityStage.POST_RESOLUTION)
	#ctx.degree = modify_value(ctx.degree, Enums.ValueType.DEGREE, ctx, Enums.ActivityStage.POST_RESOLUTION)


func _roll(ctx):
	ctx.user_roll = BasicMath.standard_roll()
	ctx.target_roll = BasicMath.standard_roll()

func _resolve(ctx):
	if imported_context and imported_context.reuse_resolution:
		ctx.result = imported_context.result
		ctx.degree = imported_context.degree
	else:
		if ctx.target is Prop:
			ctx.degree = 2
		if ctx.target is Creature:
			ctx.result = BasicMath.make_opposed_check(ctx.user_stat, ctx.user_roll, ctx.target_stat, ctx.target_roll)
			ctx.degree = BasicMath.determine_degree_success(ctx.result)
			SignalBus.dialog_show_message.emit(
				"%s rolled %d against %s's %d." % [ctx.user.data.name, ctx.user_stat+ctx.user_roll, ctx.target.data.name, ctx.target_stat+ctx.target_roll])

@warning_ignore("unused_parameter")
func _apply_effects(ctx):
	for effect in target_effects:
		pass
		#effect.apply(ctx)

func _has_enough_ap_and_pp(ctx):
	if not ctx.user.has_enough_ap(AP_cost):
		return false
	if is_spell:
		if not ctx.user.has_enough_pp(ctx.user.get_stat("current_spell_cost")):
			return false
	else:
		if not ctx.user.has_enough_pp(PP_cost):
			return false
	return true

func _consume_ap(ctx):
	ctx.user.consume_ap(AP_cost)

func _consume_pp(ctx):
	if is_spell:
		ctx.user.consume_pp(ctx.user.get_stat("current_spell_cost"))
	else:
		ctx.user.consume_pp(PP_cost)

func execute() -> void:
	pass

func can_execute() -> bool:
	for filter in self_filters:
		if filter is Filter:
			var ctx = _build_context(user)
			if not filter.is_satisfied(ctx):
				return false
	return true

func has_tag(tag: Enums.Tag) -> bool:
	return tags.has(tag)

func process_barriers(ctx: ActivityContext) -> void:
	if barrier_interaction == Enums.BarrierInteraction.STOP:
		var ctx_target = ctx.target
		if ctx_target is Entity and ctx.target.has_method("process_barriers"):
			ctx_target.process_barriers(ctx)

func is_valid_target_point(point: Vector3i, requires_los: bool = true) -> bool:
	origin = user.get_coords()

	if not WorldMath.is_in_range(origin, point, reach):
		return false

	if requires_los and not WorldMath.has_line_of_sight_tile(origin, point):
		return false

	return true

func remove_invalid_points(targets: Array[Vector3i]):
	for i in range(targets.size() - 1, -1, -1):
		if not is_valid_target_point(targets[i], reach_requires_LOS):
			targets.remove_at(i)

func compute_affected_area(target_location: Vector3i) -> Array[Vector3i]:
	match shape:
		Enums.Shape.BURST:
			return WorldMath.get_burst_tiles(target_location, spread, spread_requires_LOS)
		Enums.Shape.CONE:
			return WorldMath.get_cone_tiles(origin, target_location, reach, spread, spread_requires_LOS)
		Enums.Shape.LINE:
			var tiles = WorldMath.get_line_tiles(origin, target_location, reach)
			tiles.pop_front()
			return tiles
	return WorldMath.get_burst_tiles(target_location, spread, spread_requires_LOS)

func _init():
	if ai_hint:
		ai_hint.AP_cost = AP_cost
		ai_hint.PP_cost = PP_cost
		ai_hint.EP_cost = EP_cost
		ai_hint.reach = reach
		ai_hint.spread = spread
		ai_hint.delay = delay
