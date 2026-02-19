extends Resource
class_name CreatureData

@export var id: int = 0

@export var name: String
@export var level: int = 1
@export var species: String = ""
@export var major_archetype: Archetype = null
@export var minor_archetype: Archetype = null

@export var sprite: String = "res://art/characters/swordwraith1.png"

@export var attributes: Attributes = null
@export var base_stats: BaseStats = null
@export var inventory: Inventory = null
@export var equipment: Equipment = null
@export var resistances: Resistances = null
@export var relationships: Relationships = null

@export var personality: Personality = null

@export var talents: Array[Talent] = []
@export var activities: Array[Activity] = []
@export var spells_ready: Array = [Spell]
@export var spells_available: Array = [Spell]
@export var reactions: Array = []
@export var conditions: Array = [Condition]
@export var activity_modifiers: Array = [ActivityModifier]
@export var concentrations: Array = [Concentration]

@export var casting_table: CastingTable = null

@export var current_hp: int = 0
@export var temp_hp: int = 0
@export var current_pp: int = 0
@export var temp_pp: int = 0
@export var current_ep: int = 0
@export var temp_ep: int = 0
@export var current_mp: float = 0
@export var temp_mp: float = 0
@export var current_ap: int = 0
@export var current_reactions: int = 1
@export var current_spell_rank: int = 1
@export var max_spell_rank: int = 0

# AI Needs
@export_range(0, 100) var hunger = 100
@export_range(0, 100) var sleep = 100
@export_range(0, 100) var social = 100

# Tactical information
@export var map_id: String = ""
@export var tile_x: int = 0
@export var tile_y: int = 0
@export var tile_z: int = 0

@export var has_been_initialized: bool = false
@export var player_controlled: bool = false
@export var crisis_ai_active: bool = false
@export var alive: bool = true
@export var conscious: bool = true
@export var initiative: int = -1

var derived_stats = null
