extends Resource
class_name HTNMethod

@export var name: String = ""
@export var primitive_slots: Array[HTNPrimitiveSlot]

@export var base_utility: float = 50.0
@export var trait_weights: Dictionary = {
	caution = 50,
	sociality = 50,
	compassion = 50,
	dedication = 50,
	intelligence = 50,
	charisma = 50,
	ambition = 50,
	morale = 50,}
@export var requires_group_context: bool = false  # gates PullOut & others
