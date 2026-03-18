extends Panel

var root = null

@onready var paragon_button = $ArchetypeTabs/Archetype/VBoxContainer/HBoxContainer/Archetypes/Paragon
@onready var aspected_mage_button = $ArchetypeTabs/Archetype/VBoxContainer/HBoxContainer/Archetypes/AspectedMage

func _on_paragon_button_pressed():
	root.data.major_archetype = load("res://resources/archetypes/paragon/paragon.tres")
	print("paragon!")

func _on_aspected_mage_button_pressed():
	root.data.major_archetype = load("res://resources/archetypes/mage/mage.tres")
	print("mage!")

func _ready() -> void:
	root = $"../../../.."
	paragon_button.pressed.connect(_on_paragon_button_pressed)
	aspected_mage_button.pressed.connect(_on_aspected_mage_button_pressed)
