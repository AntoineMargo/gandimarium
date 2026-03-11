extends Resource
class_name Item

@export var name: String
@export var id: String = "placeholder"
@export var description: String
@export var icon: String
@export var weight: float = 1.0
@export var value: int = 10
@export var activities = []
@export var conditions: Array[Condition] = []
@export var slot_type: Enums.SlotType = Enums.SlotType.NONE
@export var can_be_removed: bool = true

@export var brawn_req_1h: int = 4
@export var brawn_req_2h: int = 2

@export var strike: Activity = null
@export var shoot: Activity = null
@export var throw: Activity = null

@export var count: int = 1
@export var selected_attacks: Dictionary[Enums.AttackCategory, Enums.AttackType] = {}

@export_storage var owner = null # Creature/ContainerProp/tile

func initialize_attack_modes():
	if strike:
		selected_attacks[Enums.AttackCategory.STRIKE] = strike.attack_types[0].id
	if shoot:
		selected_attacks[Enums.AttackCategory.SHOOT] = shoot.attack_types[0].id
	if throw:
		selected_attacks[Enums.AttackCategory.THROW] = throw.attack_types[0].id

func destroy():
	if owner and owner.has_method("remove_item"):
			owner.remove_item(self)
