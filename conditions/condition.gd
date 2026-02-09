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

var concentration: Concentration = null
var user = null
var target = null
var sources = {}
#var sources: Array = []

func is_active() -> bool:
	return not sources.is_empty()

func _on_concentration_ended():
	target.remove_condition(self)

func initialize(target) -> void:
	self.target = target
	if concentration and not concentration.ended.is_connected(_on_concentration_ended):
		concentration.ended.connect(_on_concentration_ended)
	for effect in effects:
		effect.apply(self, target)

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
	
#func add_source(src) -> void:
	#if not sources.has(src):
		#sources.append(src)

#func remove_source(src) -> void:
	#sources.erase(src)
	#if sources.is_empty():
		#target.remove_condition(self)
	##user.remove_condition_from(self, id)
	##target.remove_condition_from(self, id)

#func remove():
	#pass
