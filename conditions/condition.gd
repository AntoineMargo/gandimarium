extends Resource
class_name Condition

@export var name: String = "placeholder"
@export var id: String = "placeholder"
@export var description: String = "This is a placeholder description."
@export var icon: String
@export var filters: Array[Filter] = []
@export var effects: Array[Effect] = []
@export var supplanted: Array[Condition] = []
@export var duration: int = -1 # in seconds
#@export var toggle: bool = false
@export var is_visible: bool = true
@export var vfx_scene: PackedScene

var vfx_instance: Node = null
var linked_items: Array[Item] = []
var linked_modifiers: Array[ModifierEntry] = []

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
	self.target = ctx.target
	self.user = ctx.user
	if user is Creature:
		self.user_uid = user.data.uid
	self.target_uid = target.data.uid
	ctx.condition = self
	if ctx is ActivityContext:
		self.spell_rank = ctx.current_spell_rank
		if ctx.concentration:
			ctx.concentration.register_condition(self)
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
	start_time = Global.time_manager.get_total_seconds()
	if duration > 0:
		end_time = start_time + duration
		SignalBus.time_changed.connect(verify_expired)

func verify_expired(_days, _hours, _minutes, _seconds):
	if frozen:
		return

	if Global.time_manager.get_total_seconds() >= end_time:
		dispose()

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

func dispose():
	destroy_children()
	target.remove_condition(self)
	#if Global.selected_char == target:
		#SignalBus.update_inventory.emit()
		#SignalBus.update_character_info.emit()

func destroy_children():
	for item in linked_items:
		item.destroy()

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
