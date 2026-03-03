extends Resource
class_name Condition

@export var name: String = "placeholder"
@export var id: String = "placeholder"
@export var description: String = "This is a placeholder description."
@export var icon: String
@export var filters: Array[Filter] = []
@export var effects: Array[Effect] = []
@export var supplanted: Array[Condition] = []
@export var duration: int = -1
@export var toggle: bool = false
@export var is_visible: bool = true

var linked_items: Array[Item] = []
var linked_modifiers: Array[ModifierEntry] = []

var user = null
var target = null
var user_uid = null
var target_uid = null
var tile_spawned_on: Vector3i = Vector3i(0, 0, 0)
var spell_rank: int = 0
var sources = {}

func is_active() -> bool:
	return not sources.is_empty()

#func _on_concentration_ended():
	#target.remove_condition(self)

func initialize(ctx: Context) -> void:
	self.target = ctx.target
	self.user = ctx.user
	self.user_uid = user.get_final_stat("uid")
	self.target_uid = target.get_final_stat("uid")
	ctx.condition = self
	if ctx is ActivityContext:
		self.spell_rank = ctx.current_spell_rank
		if ctx.concentration:
			ctx.concentration.linked_conditions.append(self)
		#if ctx.concentration and not ctx.concentration.ended.is_connected(_on_concentration_ended):
			#ctx.concentration.ended.connect(_on_concentration_ended)
	for effect in effects:
		if effect.has_method("apply_context"):
			effect.apply_context(ctx)
		else:
			effect.apply(self, ctx.target)

func dispose():
	destroy_children()
	target.remove_condition(self)

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
