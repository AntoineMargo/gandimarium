extends Resource
class_name Condition

signal ended

# === Definition ===

@export var name: String = "placeholder"
@export var id: String = "placeholder"
@export var description: String = "This is a placeholder description."
@export var icon: String
## Survives entity's stats rebuild; not for anything spawned (items, props, creatures).
@export var persistent: bool = true
@export var re_apply_effects: bool = true
@export var filters: Array[Filter] = []
@export var effects: Array[Effect] = []
@export var triggers: Array[Trigger] = []
@export var end_requirements: Array[ConditionEndRequirement] = []
@export var supplanted: Array[Condition] = []
@export var duration: int = -1 # in seconds
#@export var toggle: bool = false
@export var is_visible: bool = true
@export var generate_semi_unique_id: bool = false

@export var vfx_scene: PackedScene

# === Runtime ===

var vfx_instance: Node = null
var linked_items: Array[Item] = []
var linked_props: Array[Prop] = []
var linked_creatures: Array[Creature] = []
var linked_modifiers: Array[Modifier] = []

var user = null
var target = null
var user_uid = null
var target_uid = null
var tile_spawned_on: Vector3i = Vector3i(0, 0, 0)
var spell_rank: int = 0
var sources = {}

var frozen: bool = false
var start_time: int
var end_time: int
var remaining_time: int

func is_active() -> bool:
	return not sources.is_empty()

func initialize(ctx: Context) -> void:
	if ctx.condition_recipient:
		self.target = ctx.condition_recipient
		self.target_uid = ctx.condition_recipient.data.uid
	else:
		self.target = ctx.target
		self.target_uid = target.data.uid
	self.user = ctx.user
	if generate_semi_unique_id:
		id = make_semi_unique_id(id, ctx.condition_recipient)
	if user is Creature:
		self.user_uid = user.data.uid

	ctx.condition = self
	if ctx is ActivityContext:
		self.spell_rank = ctx.current_spell_rank
		if ctx.concentration:
			ctx.concentration.register_condition(self)

	apply_effects(ctx)

	for end_requirement in end_requirements:
		end_requirement.setup(self)
	start_time = Global.time_manager.get_total_seconds()
	if duration > 0:
		end_time = start_time + duration
		SignalBus.time_changed.connect(verify_expired)

func apply_effects(ctx: Context = null) -> void:
	if not ctx:
		ctx = Context.new()
		ctx.user = user
		ctx.origin = user.get_coords()
		ctx.target = target
		ctx.condition = self
	for filter in filters:
		if filter is Filter:
			if not filter.is_satisfied(ctx):
				dispose()
				return
	for effect in effects:
		if effect.has_method("apply_context"):
			effect.apply_context(ctx)
		else:
			effect.apply(self, ctx.target)

func verify_expired(_days, _hours, _minutes, _seconds):
	if frozen:
		return

	if Global.time_manager.get_total_seconds() >= end_time:
		dispose()

func request_cancel() -> void:
	ended.emit()

func freeze():
	if frozen:
		return
	
	frozen = true
	var current_time = Global.time_manager.get_total_seconds()
	remaining_time = end_time - current_time
	
func unfreeze():
	if not frozen:
		return
	
	var current_time = Global.time_manager.get_total_seconds()
	if end_time - current_time != remaining_time:
		end_time = current_time + remaining_time
	frozen = false

func make_semi_unique_id(base_id: String, entity: Entity) -> String:
	var i: int = 1
	var candidate: String = base_id

	while entity.has_condition(candidate):
		candidate = "%s_%d" % [base_id, i]
		i += 1
	return candidate

func dispose():
	target.remove_condition(self)
	destroy_children()
	ended.emit()
	#if Global.selected_char == target:
		#SignalBus.update_inventory.emit()
		#SignalBus.update_character_info.emit()

func destroy_children():
	for i in range(linked_items.size() - 1, -1, -1):
		linked_items[i].destroy()
	for i in range(linked_props.size() - 1, -1, -1):
		linked_props[i].destroy_self()
	for i in range(linked_creatures.size() - 1, -1, -1):
		linked_creatures[i].destroy_self()
	for i in range(linked_modifiers.size() - 1, -1, -1):
		linked_modifiers[i].destroy()

func add_source(identifier: String):
	if not sources.has(identifier):
		sources[identifier] = 1
	else:
		sources[identifier] += 1

func remove_source(identifier: String) -> void:
	if not sources.has(identifier):
		push_warning("Tried to remove unknown source: " + identifier)
		return

	sources[identifier] -= 1

	if sources[identifier] <= 0:
		sources.erase(identifier)
	if sources.is_empty():
		dispose()

func has_source(identifier: String) -> bool:
	return sources.has(identifier)

func has_sources() -> bool:
	return not sources.is_empty()
