extends Resource
class_name WorldState

@export var map_deltas = {}

@export var creatures_by_uid: Dictionary = {}   # uid -> CreatureData

@export var creature_locations: Dictionary = {} # uid -> MapID or OvermapPosition

@export var parties_by_uid: Dictionary = {}     # uid -> PartyData
