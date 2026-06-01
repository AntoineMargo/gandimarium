extends Panel

var root = null

@onready var paragon_button = $ArchetypeTabs/Archetype/VBoxContainer/HBoxContainer/Archetypes/Paragon
@onready var aspected_mage_button = $ArchetypeTabs/Archetype/VBoxContainer/HBoxContainer/Archetypes/AspectedMage
@onready var scholastic_mage_button = $ArchetypeTabs/Archetype/VBoxContainer/HBoxContainer/Archetypes/ScholasticMage
@onready var war_mage_button = $ArchetypeTabs/Archetype/VBoxContainer/HBoxContainer/Archetypes/WarMage

func _on_paragon_button_pressed():
	root.data.major_archetype = load("res://resources/archetypes/paragon.tres")

func _on_aspected_mage_button_pressed():
	root.data.major_archetype = load("res://resources/archetypes/mage.tres")
	
func _on_scholastic_mage_button_button_pressed():
	root.data.major_archetype = load("res://resources/archetypes/scholastic_mage.tres")

func _on_war_mage_button_button_pressed():
	root.data.major_archetype = load("res://resources/archetypes/war_mage.tres")

func _ready() -> void:
	root = $"../../../.."
	paragon_button.pressed.connect(_on_paragon_button_pressed)
	aspected_mage_button.pressed.connect(_on_aspected_mage_button_pressed)
	scholastic_mage_button.pressed.connect(_on_scholastic_mage_button_button_pressed)
	war_mage_button.pressed.connect(_on_war_mage_button_button_pressed)
