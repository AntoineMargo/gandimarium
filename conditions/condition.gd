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

var concentration: Concentration = null
var user = null
var target = null
var user_uid = null
var target_uid = null
var tile_spawned_on: Vector3i = Vector3i(0, 0, 0)
var spell_rank: int = 0
var sources = {}

func is_active() -> bool:
	return not sources.is_empty()

func _on_concentration_ended():
	target.remove_condition(self)

func initialize(ctx: Context) -> void:
	self.target = ctx.target
	self.user = ctx.user
	self.user_uid = user.get_final_stat("uid")
	self.target_uid = target.get_final_stat("uid")
	if ctx is ActivityContext:
		ctx.condition = self
		self.spell_rank = ctx.current_spell_rank
		if ctx.concentration:
			concentration = ctx.concentration
			concentration.linked_conditions.append(self)
		if concentration and not concentration.ended.is_connected(_on_concentration_ended):
			concentration.ended.connect(_on_concentration_ended)
	for effect in effects:
		effect.apply(self, ctx.target)

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
		target.remove_condition(self)

func has_source(identifier: String) -> bool:
	return sources.has(identifier)

func has_sources() -> bool:
	return not sources.is_empty()
