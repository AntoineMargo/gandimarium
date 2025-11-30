extends Resource
class_name AIHint

enum CategoryType { HOSTILE, BENEFICIAL, BOTH, NEITHER }
enum ShapeType { CIRCLE, CONE, LINE, CUSTOM }
enum DamageType { PHYSICAL, HEAT, COLD, ELECTRICITY, CORROSION, POISON, PSYCHIC, RAW }
enum TargetingType { CREATURE, LOCATION, BOTH }
enum OriginType { SELF, FAMILIAR, SUMMON, ALLY, ENEMY, LOCATION }

@export var category: CategoryType = CategoryType.HOSTILE
@export var traits: Array[String] = [] # setup, dot, fire, cold, reveal, invisibility, dispel_invisibility, dispel...
@export var origin: Array[OriginType] = [OriginType.SELF]
@export var power = {
	damage = 100,
	heal = 0,
	buff = 0,
	debuff = 0,
	control = 0,
	movement = 0,
	impediment = 0,
	summon = 0,
	utility = 0}
@export var targeting_type: TargetingType = TargetingType.CREATURE # "creature" or "location"
@export var targeting_number: int = 1
@export var shape: ShapeType = ShapeType.CIRCLE
@export var requires_line_of_sight: bool = true
@export var uses_melee_weapon: bool = false
@export var uses_ranged_weapon: bool = false
@export var spell_variable_rank: bool = false
@export var friendy_fire: bool = true
@export var provokes_aoo: bool = false
@export var damage_type: Array[DamageType] = [DamageType.PHYSICAL]
@export var damage_variance: int = 5 # 1 to 10
@export var damage_certainty: int = 5 # 1 to 10

var AP_cost: int = 1
var PP_cost: int = 0 # if spell then disregarded since variable
var EP_cost: int = 0
var reach: int = 1
var spread: int = 0
var delay: int = 0
