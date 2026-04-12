extends WeaponActivity
class_name WeaponThrow

#@export var reach_mult: int = 1

func drop_item_on_target(target):
	var item_in_inventory: bool = false
	for item in user.data.inventory.list:
		if item.id == weapon.id:
			user.data.inventory.remove_item(item)
			item_in_inventory = true
			break
	if not item_in_inventory:
		user.data.equipment.remove_item(weapon)
	var wm = Global.world_manager
	var coords = target.get_coords()
	wm.add_to_tile(weapon, coords)
	wm.add_item_visual(coords)

func execute() -> void:
	#reach = user.data.attributes.brawn * reach_mult
	var final_reach = reach * user.data.attributes.brawn
	_apply_act_mods()
	var shared_ctx = _build_shared_context()
	var self_ctx = _build_context(shared_ctx, user)
	for filter in self_filters:
		if filter is Filter:
			if not filter.is_satisfied(self_ctx):
				return

	if target_entities.is_empty():
		return
	for target in target_entities:
		var ctx = _build_context(shared_ctx, target)
		if not WorldMath.char_in_range(ctx.origin, ctx.target, final_reach):
			SignalBus.dialog_out_of_range.emit()
			continue
		if not WorldMath.has_line_of_sight(ctx.origin, ctx.target):
			SignalBus.dialog_no_line_of_sight.emit()
			continue
		var passes_all_filters = true
		for filter in target_filters:
			if filter is Filter:
				if not filter.is_satisfied(ctx):
					passes_all_filters = false
					break
		if not passes_all_filters:
			continue

		_apply_pre_mods(ctx)
		_roll(ctx)
		_apply_post_mods(ctx)
		if requires_roll:
			_resolve(ctx)

		for effect in target_effects:
			if effect is Effect:
				if effect.has_method("apply_context"):
					effect.apply_context(ctx)
				else:
					effect.apply(self, ctx.target, ctx.degree)

		for effect in self_per_target_effects:
			if effect is Effect:
				if effect.has_method("apply_context"):
					effect.apply_context(ctx)
				else:
					effect.apply(self, ctx.user, ctx.degree)

		drop_item_on_target(target)

	for effect in self_final_effects:
		if effect is Effect:
			if effect.has_method("apply_context"):
				effect.apply_context(self_ctx)
			else:
				effect.apply(self, self_ctx.user, self_ctx.degree)

	_consume_ap(self_ctx)
	_consume_pp(self_ctx)
	SignalBus.update_ui_for_char.emit()
