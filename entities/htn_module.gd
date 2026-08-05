extends Node
class_name HTNModule

@onready var htn_network: HTNetwork = load("res://resources/AI/TaskLists/default_HTN.tres")
@onready var wm = Global.world_manager

func choose_strategy(report: Dictionary) -> HTNStrategy:
	return htn_network.choose_strategy(report)

func choose_tactic(report: Dictionary) -> HTNTactic:
	var strategy: HTNStrategy = report["strategy"]
	return strategy.choose_tactic(report)

func choose_method(report: Dictionary) -> HTNMethod:
	var tactic: HTNTactic = report["tactic"]
	return tactic.choose_method(report)

func enough_AP(activity: Activity, report: Dictionary) -> bool:
	if activity.AP_cost > report["remaining_AP"]:
		return false
	return true
	
func enough_PP(activity: Activity, report: Dictionary) -> bool:
	if activity.PP_cost > report["remaining_PP"]:
		return false
	return true
	
func enough_EP(activity: Activity, report: Dictionary) -> bool:
	if activity.EP_cost > report["remaining_EP"]:
		return false
	return true

func has_all_wanted_tags(wanted_act: WantedAct, entry: ActivityVariant) -> bool:
	var activity_tags = entry.ai_hint.act_tags
	var wanted_tags = wanted_act.wanted_tags

	for wanted_tag in wanted_tags:
		var activity_tag: ActTag = null 

		for tag in activity_tags:
			if wanted_tag.tag == tag.tag:
				activity_tag = tag
				break

		if not activity_tag:
			return false
		if activity_tag.value < wanted_tag.value:
			return false

	return true

func has_unwanted_tag(wanted_act: WantedAct, entry: ActivityVariant) -> bool:
	var activity_tags = entry.ai_hint.act_tags
	var unwanted_tags = wanted_act.unwanted_tags

	for unwanted_tag in unwanted_tags:
		for tag in activity_tags:
			if unwanted_tag.tag == tag.tag and tag.value >= unwanted_tag.value:
				return true

	return false

func calculate_overvalue(entry: ActivityVariant, wanted_act: WantedAct) -> float:
	var overvalue: float = 0
	
	var activity_tags = entry.ai_hint.act_tags
	var wanted_tags = wanted_act.wanted_tags
	var unwanted_tags = wanted_act.unwanted_tags

	for wanted_tag in wanted_tags:
		for tag in activity_tags:
			if wanted_tag.tag == tag.tag:
				var headroom: float = 100.0 - wanted_tag.value
				if headroom > 0.0:
					var excess_fraction: float = (tag.value - wanted_tag.value) / headroom
					overvalue += excess_fraction * wanted_tag.weight
				break

	for unwanted_tag in unwanted_tags:
		for tag in activity_tags:
			if unwanted_tag.tag == tag.tag:
				if unwanted_tag.value > 0.0:
					var safety_fraction: float = (unwanted_tag.value - tag.value) / unwanted_tag.value
					overvalue += safety_fraction * unwanted_tag.weight
				break

	return overvalue

func choose_target(wanted_act: WantedAct, planned_act: PlannedAct, report: Dictionary):
	var hint = planned_act.activity_variant.ai_hint
	match hint.targeting_type:
		Enums.Targeting.TILES:
			if wanted_act.requirement_to:
				var requirement_to = wanted_act.requirement_to
				for wanted_tag in wanted_act.wanted_tags:
					if wanted_tag.tag == Enums.ActivityTag.MOVEMENT:
						if not requirement_to.targets.is_empty():
							var target = requirement_to.targets[0]
							var distance: int = requirement_to.pre_executed.reach
							var origin = report["creature"].get_coords()
							var path = wm.path_to_adjacency(target, origin, distance)
							var in_range_tile: Vector3i = path[-1]
							planned_act.targets.append(in_range_tile)
							requirement_to.position = in_range_tile

		Enums.Targeting.ENTITIES, Enums.Targeting.CREATURES:
			match hint.category:
				Enums.ActivityCategory.HOSTILE:
					if report["closest_enemy"]:
						planned_act.targets.append(report["closest_enemy"].get_coords())

				Enums.ActivityCategory.BENEFICIAL:
					if report["closest_ally"]:
						planned_act.targets.append(report["closest_ally"].get_coords())

func find_best_activity(wanted_act: WantedAct, report: Dictionary) -> ActivityVariant:
	var entries = report["entries"]
	var best_entry: ActivityVariant = null
	var best_overvalue: float = 0.0
	var overvalue: float

	for entry in entries:
		if not entry.ai_hint:
			continue
		#var final_entry = entry.pre_execute(report["creature"])
		overvalue = 0.0
		if has_unwanted_tag(wanted_act, entry):
			continue
		if not has_all_wanted_tags(wanted_act, entry):
			continue
		#if not enough_AP(final_entry, report):
			#continue
		#if not enough_PP(final_entry, report):
			#continue
		#if not enough_EP(final_entry, report):
			#continue

		overvalue = calculate_overvalue(entry, wanted_act)
		if overvalue >= best_overvalue:
			best_overvalue = overvalue
			best_entry = entry

	if best_entry == null:
		print("Couldn't find any fitting activity!")
	return best_entry

func calculate_total_AP_cost(planned_acts: Array[PlannedAct], _report: Dictionary) -> int:
	var total_cost: int = 0
	for element in planned_acts:
		total_cost += element.AP_cost
	return total_cost

func is_in_range(ctx: ActivityContext) -> bool:
	if ctx.activity.is_valid_target_point(ctx.target, ctx.origin):
		return true
	else:
		return false

func get_resource_costs(_wanted_act: WantedAct,planned_act: PlannedAct, report: Dictionary) -> void:
	if not planned_act.pre_executed:
		return
	var activity: Activity = planned_act.pre_executed

	if activity.id == "act_move":
		var path = wm.get_multi_level_path(planned_act.position, planned_act.targets[0], true)
		if path:
			var cost = wm.calculate_path_cost_3D_simple(path)
			planned_act.MP_cost = cost
			
			var existing_mp: int = report["creature"].get_stat("current_mp")
			var max_mp: int = report["creature"].get_stat("max_mp")
			
			if cost <= existing_mp:
				planned_act.AP_cost = 0
			else:
				var missing_mp: float = cost - existing_mp
				planned_act.AP_cost = int(ceil(float(missing_mp) / max_mp))

			planned_act.PP_cost = activity.PP_cost
	else:
		planned_act.AP_cost = activity.AP_cost
		planned_act.PP_cost = activity.PP_cost


func check_step_requirements(planned_acts: Array[PlannedAct], wanted_acts: Array[WantedAct], report: Dictionary, i: int) -> bool:
	var all_clear: bool = true
	var activity: Activity = null
	
	var planned_act: PlannedAct = planned_acts[i]
	#var wanted_act: WantedAct = wanted_acts[i]
	
	if planned_act.pre_executed:
		activity = planned_act.pre_executed
	else:
		activity = planned_act.activity_variant.pre_execute(report["creature"])

	var ctx = ActivityContext.new()
	ctx.activity = activity
	ctx.user = report["creature"]
	ctx.origin = planned_act.position
	ctx.target = planned_act.targets[0]

	if not is_in_range(ctx):
		var new_wanted_act = WantedAct.new()
		new_wanted_act.requirement_to = planned_act
		var act_tag: ActTag = ActTag.new()
		act_tag.create(Enums.ActivityTag.MOVEMENT, 40)
		new_wanted_act.wanted_tags.append(act_tag)
		new_wanted_act.modifies_position = true
		wanted_acts.insert(i, new_wanted_act)
		planned_acts.insert(i, null)
		print("Inserting movement wanted_act at index %d" % [i])
		all_clear = false
		
	return all_clear

func choose_optimal_attack_type(planned_act: PlannedAct):
	var activity = planned_act.pre_executed
	if !activity:
		return

	var attack_types: Array[DamagePattern] = activity.attack_types
	if !attack_types:
		return

	var main_target = planned_act.targets[0]
	var entity: Entity = wm.get_entity_at_pos(main_target)
	if entity is Creature:
		if entity.perceive_armour() is Armour:
			for attack_type in attack_types: 
				if attack_type.id == 1: # if activity's weapon has "pierce"
					activity.weapon.selected_attacks[Enums.AttackCategory.STRIKE] = Enums.AttackType.PIERCE
				if attack_type.id == 2: # if activity's weapon has "crush"
					activity.weapon.selected_attacks[Enums.AttackCategory.STRIKE] = Enums.AttackType.CRUSH

func update_positions(wanted_acts: Array[WantedAct], planned_acts: Array[PlannedAct], i: int) -> void:
	var wanted_act = wanted_acts[i]
	var planned_act = planned_acts[i]
	
	if planned_act.targets.is_empty():
		return
	
	var new_position: Vector3i = planned_act.targets[-1]
	
	i += 1
	while i < wanted_acts.size():
		wanted_act = wanted_acts[i]
		planned_act = planned_acts[i]
		
		planned_act.position = new_position
		
		if wanted_act.modifies_position:
			break
		
		i += 1

func produce_sequence(report) -> Array[PlannedAct]:
	report["strategy"] = choose_strategy(report)
	report["tactic"] = choose_tactic(report)
	report["method"] = choose_method(report)
	var wanted_acts: Array[WantedAct] =  report["method"].wanted_acts.duplicate()
	var planned_acts: Array[PlannedAct] = []
	var total_ap_cost: int = 0
	
	planned_acts.resize(wanted_acts.size())

	var i: int = 0
	while i < wanted_acts.size():
		var wanted_act = wanted_acts[i]
		var planned_act = planned_acts[i]
		
		if not planned_act:
			planned_act = PlannedAct.new()
			planned_acts[i] = planned_act
			planned_act.position = report["original_pos"]
			if i > 0:
				var previous_planned_act: PlannedAct = planned_acts[i - 1]
				if previous_planned_act and previous_planned_act.position != Vector3i(-1, -1, -1):
					planned_act.position = previous_planned_act.position
			planned_act.activity_variant = find_best_activity(wanted_act, report)
			if planned_act.activity_variant == null:
				if !wanted_act.optional:
					return []
				i += 1
				continue
			
			planned_act.pre_executed = planned_act.activity_variant.pre_execute(report["creature"])
			choose_target(wanted_act, planned_act, report)
			if wanted_act.modifies_position:
				update_positions(wanted_acts, planned_acts, i)
				
			choose_optimal_attack_type(planned_act)
			get_resource_costs(wanted_act, planned_act, report)
			total_ap_cost += planned_act.AP_cost
			if not check_step_requirements(planned_acts, wanted_acts, report, i):
				continue

		if i == (wanted_acts.size() - 1):
			if total_ap_cost < report["AP"] and wanted_act.repeatable:
				wanted_acts.append(wanted_act.duplicate())
				planned_acts.append(null)
				print("Inserting repeatable wanted_act at index %d" % [i + 1])

		i += 1

	report["total_AP_cost"] =  calculate_total_AP_cost(planned_acts, report)

	return planned_acts


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
