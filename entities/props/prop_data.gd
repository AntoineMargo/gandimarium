extends Resource
class_name PropData

@export var uid: int = 0

@export var name: String = "prop"
@export var id: String = "prop"
@export var icon: Texture2D = null
@export var texture: Texture2D = null
#@export var scene: PackedScene
@export var blocks_movement: bool = true
@export var max_hp: int = 40

@export var cover: Enums.Cover
@export_storage var is_runtime: bool = false

@export_storage var map_id: String
@export_storage var pos: Vector3i = Vector3i(-1, -1, -1)
@export_storage var current_hp: int = 0
@export_storage var is_active: bool = false

# Resistances
@export var physical: int = 0
@export var heat: int = 0
@export var cold: int = 0
@export var electricity: int = 0
@export var corrosion: int = 0
@export var poison: int = 0
@export var psychic: int = 0

## If the prop was created by a Condition.
@export_storage var linked_condition: Condition = null

#@export var mat: Enums.Mat
