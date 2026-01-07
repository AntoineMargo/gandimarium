extends Resource
class_name Relationships

# strategic layer
@export var affiliations: Array[AffiliationEntry] = []
@export var reputations: Array[ReputationEntry] = []

# tactical layer
@export var tactical_relations: Array[TacticalRelationEntry] = []

var _tactical_map: Dictionary = {}

func build_tactical_map(): # to be built on init, for runtime use
	_tactical_map.clear()
	for entry in tactical_relations:
		_tactical_map[entry.target_id] = entry

func get_tactical(target_id: String) -> TacticalRelationEntry:
	return _tactical_map.get(target_id, null)
