extends Resource
class_name CreatureData

@export var id: int = 0 # deprecated
@export var uid: int = 0

@export var name: String
@export var level: int = 1
@export var species: String = ""
@export var major_archetype: Archetype = null
@export var minor_archetype: Archetype = null
@export var discipline = null

@export var sprite: String = "res://art/characters/hooded_char.png"

@export var attributes: Attributes = null
@export var skills: Skills = null
@export var base_stats: BaseStats = null
@export var inventory: Inventory = null
@export var equipment: Equipment = null
@export var resistances: Resistances = null
@export var relationships: Relationships = null
@export var personality: Personality = null

@export var aspects: Array[Aspect] = []
@export var talents: Array[Talent] = []
@export var activities: Array[ActivityContainer] = []
@export var spells_ready: Array[SpellContainer] = []
@export var spells_available: Array[SpellContainer] = []
@export var reactions: Array[Reaction] = []
@export var conditions: Array[Condition] = []
@export var activity_modifiers: Array[Modifier] = []
@export var concentrations: Array[Concentration] = []
@export var barriers: Array[Barrier] = []

# map ID String, Array of int UIDs
@export var owned_rooms: Dictionary[String, Array] = {}
@export var owned_buildings: Dictionary[String, Array] = {}

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
@export var max_spells_ready: int = 0

# Needs
@export_range(0, 10000) var hunger: int = 10000
@export_range(0, 10000) var sleep: int = 10000
@export_range(0, 10000) var social: int = 10000

# Tactical information
@export var map_id: String = ""
@export var tile_x: int = 0
@export var tile_y: int = 0
@export var tile_z: int = 0

@export var has_been_initialized: bool = false
@export var player_controlled: bool = false
@export var crisis_ai_active: bool = false
@export var alive: bool = true
@export var targetable: bool = true

@export var sight: Enums.Capability = Enums.Capability.NORMAL
@export var hearing: Enums.Capability = Enums.Capability.NORMAL

@export var visibility: Enums.Capability = Enums.Capability.NORMAL
@export var audibility: Enums.Capability = Enums.Capability.NORMAL

@export var state: Enums.State = Enums.State.CONSCIOUS

@export var initiative: int = -1

var derived_stats = null
