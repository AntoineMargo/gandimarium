extends Resource
class_name Activity

enum AffectedType {
	ENTITIES,
	TERRAIN,
	ENTITIES_OR_TERRAIN,
	ENTITIES_AND_TERRAIN
}

enum ShapeType {
	CIRCLE,
	CONE,
	LINE,
	CUSTOM
}

@export var name: String = "placeholder"
@export var id: String = "placeholder"
@export var description: String = "This is a placeholder description."
@export var icon: String = "res://art/interface/activities/placeholder1.png"
@export var tags: Array[String] = []
@export var AP_cost: int = 1
@export var PP_cost: int = 0
@export var EP_cost: int = 0
@export var requires_concentration: bool = false
@export var attacking_aptitude: String = "will"
@export var defending_aptitude: String = "will"
@export var reach: int = 0
@export var spread: int = 0
@export var delay: int = 0

@export var self_filters: Array[Filter] = []
@export var self_per_target_effects: Array[Effect] = []
@export var self_final_effects: Array[Effect] = []

@export var target_filters: Array[Filter] = []
@export var target_effects: Array[Effect] = []
@export var affected_type: AffectedType = AffectedType.ENTITIES
@export var shape: ShapeType = ShapeType.CIRCLE

@export var minimum_rank: int = 1

@export var requires_crisis: bool = true
@export var requires_roll: bool = true
@export var is_invisible: bool = false
@export var is_spell: bool = false
@export var builds_condition: bool = false
@export var condition_id: String = ""
@export var ai_hint: AIHint


var user = null
var origin: Vector3i
var concentration = null
var target_points = []
var target_entities = []

func _setup_concentration():
	if requires_concentration:
		concentration = Concentration.new()
		concentration.source = self
	

func _finalize_concentration():
	#if requires_concentration and concentration:
		#user.add_concentration(concentration)
		#concentration = null
	if requires_concentration:
		if concentration.has_connections("ended"):
			user.add_concentration(concentration)
		else:
			concentration.cancel()
	

func _build_context(target = null):
	var ctx = ActivityContext.new()
	ctx.activity = self
	ctx.user = user
	ctx.target = target
	ctx.origin = user
	
	ctx.user_stat = user.get_final_stat(attacking_aptitude)
	if ctx.target is Creature:
		ctx.target_stat = target.get_final_stat(defending_aptitude)
	else:
		ctx.target_stat = 0

	return ctx

func _apply_act_mods():
	for modifier in user.data.activity_modifiers:
		modifier.modify_activity(self)

func _apply_pre_mods(ctx):
	for modifier in user.data.activity_modifiers:
		modifier.apply_pre_mods(ctx)

func _apply_post_mods(ctx):
	for modifier in user.data.activity_modifiers:
		modifier.apply_post_mods(ctx)

func _roll(ctx):
	ctx.user_roll = CombatMath.standard_roll()
	ctx.target_roll = CombatMath.standard_roll()

func _resolve(ctx):
	ctx.result = CombatMath.make_opposed_check(ctx.user_stat, ctx.user_roll, ctx.target_stat, ctx.target_roll)
	ctx.degree = CombatMath.determine_degree_success(ctx.result)
	
	if ctx.target is Creature:
		SignalBus.dialog_show_message.emit(
			"%s rolled %d against %s's %d." % [ctx.user.data.name, ctx.user_stat+ctx.user_roll, ctx.target.data.name, ctx.target_stat+ctx.target_roll])

@warning_ignore("unused_parameter")
func _apply_effects(ctx):
	for effect in target_effects:
		pass
		#effect.apply(ctx)

func _consume_ap(ctx):
	if requires_crisis and Global.crisis_manager.crisis_mode:
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

func has_tag(tag: String) -> bool:
	return tags.has(tag)

func _init():
	if ai_hint:
		ai_hint.AP_cost = AP_cost
		ai_hint.PP_cost = PP_cost
		ai_hint.EP_cost = EP_cost
		ai_hint.reach = reach
		ai_hint.spread = spread
		ai_hint.delay = delay
