extends Node
class_name HTNModule

@onready var tasks: HTNTaskList = load("res://resources/AI/TaskLists/default_task_list.tres")
@onready var wm = Global.world_manager

func choose_task(report: Dictionary) -> HTNTask:
	for task in tasks.list:
		if task.name == "EngageEnemy":
			return task
	return null

func choose_method(report: Dictionary) -> HTNMethod:
	var task: HTNTask = report["task"]
	if task.methods.is_empty():
		return null

	var best_method: HTNMethod = null

	for method in task.methods:
		if !best_method or method.base_utility > best_method.base_utility:
			best_method = method
	return best_method

func has_all_wanted_tags(slot: HTNPrimitiveSlot, entry: ActivityVariant) -> bool:
	var activity_tags = entry.activity.ai_hint.tags
	for tag in slot.wanted_tags:
		if tag not in activity_tags:
			return false
	return true

func has_unwanted_tag(slot: HTNPrimitiveSlot, entry: ActivityVariant) -> bool:
	var activity_tags = entry.activity.ai_hint.tags
	for tag in slot.unwanted_tags:
		if tag in activity_tags:
			return true
	return false

func has_correct_primitive_type(slot: HTNPrimitiveSlot, entry: ActivityVariant) -> bool:
	var primitive_type: int = get_primitive_type_power(slot, entry)
	if primitive_type > 0:
		return true
	else:
		return false

func get_primitive_type_power(slot: HTNPrimitiveSlot, entry: ActivityVariant) -> int:
	var power = entry.activity.ai_hint.power
	match slot.primitive_type:
		Enums.PrimitiveType.DAMAGE:
			return power["damage"]
		Enums.PrimitiveType.HEAL:
			return power["heal"]
		Enums.PrimitiveType.BUFF:
			return power["buff"]
		Enums.PrimitiveType.DEBUFF:
			return power["debuff"]
		Enums.PrimitiveType.CONTROL:
			return power["control"]
		Enums.PrimitiveType.MOVEMENT:
			return power["movement"]
		Enums.PrimitiveType.IMPEDIMENT:
			return power["impediment"]
		Enums.PrimitiveType.SUMMON:
			return power["summon"]
		Enums.PrimitiveType.UTILITY:
			return power["utility"]
	return false


func enough_AP(final_entry: Activity, report: Dictionary) -> bool:
	if final_entry.AP_cost > report["remaining_AP"]:
		return false
	return true
	
	
func enough_PP(final_entry: Activity, report: Dictionary) -> bool:
	if final_entry.PP_cost > report["remaining_PP"]:
		return false
	return true
	
#func enough_EP(final_entry: Activity, report: Dictionary) -> bool:
	#if final_entry.EP_cost > report["remaining_EP"]:
		#return false
	#return true


func match_candidates_to_slot(slot: HTNPrimitiveSlot, report: Dictionary) -> Array[ActivityVariant]:
	var entries = report["entries"]
	var candidates: Array[ActivityVariant] = []
	for entry in entries:
		var final_entry = entry.pre_execute(report["creature"])
		if not has_correct_primitive_type(slot, entry):
			continue
		if has_unwanted_tag(slot, entry):
			continue
		if not has_all_wanted_tags(slot, entry):
			continue
		#if not enough_AP(final_entry, report):
			#continue
		#if not enough_PP(final_entry, report):
			#continue
		#if not enough_EP(final_entry, report):
			#continue
		candidates.append(entry)
	return candidates

# Arbitrate here whether satisfying the best candidate's preconditions
# is better than picking one whose preconditions are already met
func choose_among_candidates(candidates: Array[ActivityVariant], 
							primitive_slot: HTNPrimitiveSlot, 
							report: Dictionary) -> HTNPrimitive:
	var ap_ceiling: int = -1
	if primitive_slot.skip == Enums.Skip.MISSING_AP and primitive_slot.primitive:
		ap_ceiling = primitive_slot.AP_cost

	var best_candidate: ActivityVariant = null
	var best_power: int = 0

	for candidate in candidates:
		if ap_ceiling > -1:
			var final_activity = candidate.pre_execute(report["creature"])
			if final_activity.AP_cost >= ap_ceiling:
				continue

		var candidate_power = get_primitive_type_power(primitive_slot, candidate)
		if candidate_power > best_power:
			best_candidate = candidate
			best_power = candidate_power
	if best_candidate:
		primitive_slot.primitive = HTNPrimitive.new(best_candidate, report["creature"])
		return primitive_slot.primitive
	else:
		return null

func is_in_range(ctx: ActivityContext) -> bool:
	if ctx.activity.is_valid_target_point(ctx.target):
		return true
	else:
		return false

func check_step_preconditions(primitive_slot: HTNPrimitiveSlot, report: Dictionary) -> bool:
	var primitive: HTNPrimitive = primitive_slot.primitive
	var all_clear: bool = true
	var final_activity = primitive.activity_variant.pre_execute(report["creature"])
	var ctx = ActivityContext.new()
	ctx.activity = final_activity
	ctx.user = report["creature"]
	ctx.origin = ctx.user.get_coords()
	ctx.target = primitive_slot.targets[0]

	if not is_in_range(ctx):
		var new_primitive_slot = HTNPrimitiveSlot.new(Enums.PrimitiveType.MOVEMENT, Enums.TargetType.SELF)
		new_primitive_slot.requirement_to = primitive_slot
		new_primitive_slot.core = false
		for target in primitive_slot.targets:
			var path = wm.path_to_target_adjacency(report["creature"], target, final_activity.reach)
			var in_range_tile: Vector3i = path[-1]
			new_primitive_slot.targets.append(in_range_tile)
		report["method"].primitive_slots.push_front(new_primitive_slot)
		all_clear = false
		
	return all_clear

func choose_target(primitive_slot: HTNPrimitiveSlot, report: Dictionary):
	match primitive_slot.primitive_type:
		Enums.PrimitiveType.DAMAGE:
			if report["closest_enemy"]:
				var coords = report["closest_enemy"].get_coords()
				primitive_slot.targets.append(coords)

func get_primitive_resource_costs(primitive_slot: HTNPrimitiveSlot, report: Dictionary) -> void:
	var final_activity: Activity = primitive_slot.primitive.pre_executed
	if !final_activity:
		return

	if final_activity.id == "act_move":
		var requirement_to: HTNPrimitiveSlot = primitive_slot.requirement_to

		var path = wm.get_multi_level_path_for_creature(report["creature"], primitive_slot.targets[0])
		if path:
			var cost = wm.calculate_path_cost_3D_simple(path)
			primitive_slot.MP_cost = cost
			primitive_slot.AP_cost = 1 + (cost / report["creature"].get_stat("max_mp"))
			primitive_slot.PP_cost = final_activity.PP_cost
	else:
		primitive_slot.AP_cost = final_activity.AP_cost
		primitive_slot.PP_cost = final_activity.PP_cost

func get_method_ap_cost(report: Dictionary) -> int:
	var method: HTNMethod = report["method"]
	var slots: Array[HTNPrimitiveSlot] = method.primitive_slots
	var ap_used: int = 0

	for slot in slots:
		ap_used += slot.AP_cost

	return ap_used

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

func choose_primitives(report: Dictionary) -> Array[HTNPrimitiveSlot]:
	var slots: Array[HTNPrimitiveSlot] = report["method"].primitive_slots
	var i: int = 0

	while i < slots.size():
		if slots[i].primitive:
			
			if i == (slots.size() - 1) and slots[i].repeatable:
				var ap_cost: int = get_method_ap_cost(report)
				var ap_difference: int = report["AP"] - ap_cost
				if ap_difference > 0:
					var new_primitive_slot = slots[i].duplicate(true)
					slots.append(new_primitive_slot)
			
			i += 1
			continue

		choose_target(slots[i], report)

		var candidates = match_candidates_to_slot(slots[i], report)
		var _primitive = choose_among_candidates(candidates, slots[i], report)

		get_primitive_resource_costs(slots[i], report)

		if not check_step_preconditions(slots[i], report):
			i = 0
			continue

	return slots

#func choose_primitives(report: Dictionary) -> Array[HTNPrimitiveSlot]:
	#var slots: Array[HTNPrimitiveSlot] = report["method"].primitive_slots
	#var i: int = 0
#
	#while i < slots.size():
		#if slots[i].primitive:
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
		#if i == (slots.size() - 1) and slots[i].repeatable:
			#var ap_cost: int = get_method_ap_cost(report)
			#var ap_difference: int = report["AP"] - ap_cost
			#if ap_difference > 0:
				#var new_primitive_slot = slots[i].duplicate(true)
				#slots.append(new_primitive_slot)
	#return slots

#func fix_sequence(report: Dictionary) -> Array[HTNPrimitiveSlot]:
	#var slots: Array[HTNPrimitiveSlot] = report["method"].primitive_slots
	#var i: int = 0
#
	#while i < slots.size():
		#if slots[i].skip == Enums.Skip.PROCEED:
			#i += 1
			#continue
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

#func validate_sequence(report) -> bool:
	#var valid: bool = true
	#var primitive_slots: Array[HTNPrimitiveSlot] = report["method"].primitive_slots
	#var available_ap: int = report["creature"].get_stat("max_ap")
	#var left_ap: int = available_ap
	#for primitive_slot in primitive_slots:
		#left_ap -= primitive_slot.AP_cost
		#if left_ap < 0:
			#primitive_slot.skip = Enums.Skip.MISSING_AP
			#valid = false
	#
	#return valid

func produce_sequence(report) -> Array:
	report["task"] = choose_task(report).duplicate(true)
	report["method"] = choose_method(report).duplicate(true)
	
	choose_primitives(report)
	#validate_sequence(report)
	
	#if not validate_sequence(report):
		#fix_sequence(report)

	return report["method"].primitive_slots



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
