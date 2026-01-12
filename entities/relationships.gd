extends Resource
class_name Relationships

# strategic layer
@export var affiliations: Array[AffiliationEntry] = []
@export var reputations: Array[ReputationEntry] = []

# tactical layer
@export var tactical_relations: Array[TacticalRelationEntry] = []

var _tactical_map: Dictionary = {}

var _hostile_ids: Dictionary[int, bool]
var _fearful_ids: Dictionary[int, bool]
var _suspicious_ids: Dictionary[int, bool]
var _cooperative_ids: Dictionary[int, bool]
var _protective_ids: Dictionary[int, bool]

func build_tactical_map(): # to be built on init, for runtime use
	_tactical_map.clear()
	for entry in tactical_relations:
		_tactical_map[entry.target_id] = entry

func get_tactical(target_id: int) -> TacticalRelationEntry:
	return _tactical_map.get(target_id, null)

func set_hostile(target_id: int, value: int):
	var entry = _tactical_map[target_id]
	entry.hostile = clamp(value, 0, 100)

	if entry.hostile > 0:
		_hostile_ids[target_id] = true
	else:
		_hostile_ids.erase(target_id)

func set_fearful(target_id: int, value: int):
	var entry = _tactical_map[target_id]
	entry.fearful = clamp(value, 0, 100)

	if entry.fearful > 0:
		_fearful_ids[target_id] = true
	else:
		_fearful_ids.erase(target_id)
