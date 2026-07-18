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
		push_error("Couldn't find any fitting activity!")
	return best_entry

func calculate_total_AP_cost(planned_acts: Array[PlannedAct], _report: Dictionary) -> int:
	var total_cost: int = 0
	for element in planned_acts:
		total_cost += element.AP_cost
	return total_cost

func is_in_range(ctx: ActivityContext) -> bool:
	if ctx.activity.is_valid_target_point(ctx.target):
		return true
	else:
		return false

func get_resource_costs(wanted_act: WantedAct,planned_act: PlannedAct, report: Dictionary) -> void:
	if not planned_act.pre_executed:
		return
	var activity: Activity = planned_act.pre_executed

	if activity.id == "act_move":
		var requirement_to: PlannedAct = wanted_act.requirement_to

		var path = wm.get_multi_level_path_for_creature(report["creature"], requirement_to.targets[0])
		if path:
			var cost = wm.calculate_path_cost_3D_simple(path)
			planned_act.MP_cost = cost
			
			var existing_mp: int = report["creature"].get_stat("current_mp")
			var max_mp: int = report["creature"].get_stat("max_mp")
			
			if cost < existing_mp: 
				planned_act.AP_cost = 0
			else:
				planned_act.AP_cost = 1
				@warning_ignore("narrowing_conversion")
				planned_act.AP_cost += (cost - existing_mp) / max_mp

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
	if planned_act.position != Vector3i(-1, -1, -1):
		ctx.origin = planned_act.position
	else:
		ctx.user.get_coords()
	ctx.target = planned_act.targets[0]

	if not is_in_range(ctx):
		var new_wanted_act = WantedAct.new()
		new_wanted_act.requirement_to = planned_act
		var act_tag: ActTag = ActTag.new()
		act_tag.create(Enums.ActivityTag.MOVEMENT, 40)
		new_wanted_act.wanted_tags.append(act_tag)
		wanted_acts.insert(i, new_wanted_act)
		planned_acts.insert(i, null)
		print("Inserting movement wanted_act at index %d" % [i])
		all_clear = false
		
	return all_clear

func choose_optimal_attack_type(primitive_slot: HTNPrimitiveSlot):
	var activity = primitive_slot.primitive.pre_executed
	var attack_types: Array[DamagePattern] = activity.attack_types
	if !attack_types:
		return

	var main_target = primitive_slot.targets[0]
	var entity: Entity = wm.get_entity_at_pos(main_target)
	if entity is Creature:
		if entity.perceive_armour() is Armour:
			for attack_type in attack_types: 
				if attack_type.id == 1: # if activity's weapon has "pierce"
					activity.weapon.selected_attacks[Enums.AttackCategory.STRIKE] = Enums.AttackType.PIERCE
				if attack_type.id == 2: # if activity's weapon has "crush"
					activity.weapon.selected_attacks[Enums.AttackCategory.STRIKE] = Enums.AttackType.CRUSH


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
			planned_act.activity_variant = find_best_activity(wanted_act, report)
			if planned_act.activity_variant == null:
				i += 1
				continue
			
			planned_act.pre_executed = planned_act.activity_variant.pre_execute(report["creature"])
			choose_target(wanted_act, planned_act, report)
			get_resource_costs(wanted_act, planned_act, report)
			total_ap_cost += planned_act.AP_cost
			if not check_step_requirements(planned_acts, wanted_acts, report, i):
				continue
		
		if planned_act.position == Vector3i(-1, -1, -1):
			planned_act.position = report["original_pos"]
			if i > 0:
				var previous_planned_act: PlannedAct = planned_acts[i - 1]
				if previous_planned_act and previous_planned_act.position != Vector3i(-1, -1, -1):
					planned_act.position = previous_planned_act.position
		
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

# Arbitrate here whether satisfying the best candidate's preconditions
# is better than picking one whose preconditions are already met
#func choose_among_candidates(candidates: Array[ActivityVariant], 
							#primitive_slot: HTNPrimitiveSlot, 
							#report: Dictionary) -> HTNPrimitive:
	#var ap_ceiling: int = -1
	#if primitive_slot.skip == Enums.Skip.MISSING_AP and primitive_slot.primitive:
		#ap_ceiling = primitive_slot.AP_cost
#
	#var best_candidate: ActivityVariant = null
	#var best_power: int = 0
#
	#for candidate in candidates:
		#if ap_ceiling > -1:
			#var final_activity = candidate.pre_execute(report["creature"])
			#if final_activity.AP_cost >= ap_ceiling:
				#continue
#
		#var candidate_power = get_primitive_type_power(primitive_slot, candidate)
		#if candidate_power > best_power:
			#best_candidate = candidate
			#best_power = candidate_power
	#if best_candidate:
		#primitive_slot.primitive = HTNPrimitive.new(best_candidate, report["creature"])
		#return primitive_slot.primitive
	#else:
		#return null

#func get_primitive_resource_costs(primitive_slot: HTNPrimitiveSlot, report: Dictionary) -> void:
	#var final_activity: Activity = primitive_slot.primitive.pre_executed
	#if !final_activity:
		#return
#
	#if final_activity.id == "act_move":
		#var _requirement_to: HTNPrimitiveSlot = primitive_slot.requirement_to
#
		#var path = wm.get_multi_level_path_for_creature(report["creature"], primitive_slot.targets[0])
		#if path:
			#var cost = wm.calculate_path_cost_3D_simple(path)
			#primitive_slot.MP_cost = cost
			#
			#var existing_mp: int = report["creature"].get_stat("current_mp")
			#var max_mp: int = report["creature"].get_stat("max_mp")
			#
			#if cost < existing_mp: 
				#primitive_slot.AP_cost = 0
			#else:
				#primitive_slot.AP_cost = 1
				#@warning_ignore("narrowing_conversion")
				#primitive_slot.AP_cost += (cost - existing_mp) / max_mp
				#
			##primitive_slot.AP_cost = 1 + (cost / report["creature"].get_stat("max_mp"))
			#primitive_slot.PP_cost = final_activity.PP_cost
	#else:
		#primitive_slot.AP_cost = final_activity.AP_cost
		#primitive_slot.PP_cost = final_activity.PP_cost

#func get_sequence_ap_cost(sequence: Array[PlannedAct]) -> int:
	#var ap_used: int = 0
#
	#for act in sequence:
		#ap_used += act.AP_cost
#
	#return ap_used

#func choose_primitives(report: Dictionary) -> Array[HTNPrimitiveSlot]:
	#var slots: Array[HTNPrimitiveSlot] = report["method"].primitive_slots
	#var i: int = 0
#
	#while i < slots.size():
		#if slots[i].primitive:
			#
			#if i == (slots.size() - 1) and slots[i].repeatable:
				#var ap_cost: int = get_method_ap_cost(report)
				#var ap_difference: int = report["AP"] - ap_cost
				#if ap_difference > 0:
					#var new_primitive_slot = slots[i].duplicate(true)
					#slots.append(new_primitive_slot)
			#
			#i += 1
			#continue
#
		#choose_target(slots[i], report)
#
		#var candidates = match_candidates_to_slot(slots[i], report)
		#var _primitive = choose_among_candidates(candidates, slots[i], report)
#
		#get_primitive_resource_costs(slots[i], report)
#
		#if not check_step_preconditions(slots[i], report):
			#i = 0
			#continue
#
	#return slots
#
