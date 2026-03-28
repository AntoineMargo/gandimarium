extends Control

var data: CreatureData = null


@onready var creation_tabs = $ColorRect/VBoxContainer/CreationTabs

@onready var primary_archetype = $ColorRect/VBoxContainer/CreationTabs/PrimaryArchetype
@onready var attributes = $ColorRect/VBoxContainer/CreationTabs/Attributes
@onready var skills = $ColorRect/VBoxContainer/CreationTabs/Skills
@onready var finish = $ColorRect/VBoxContainer/CreationTabs/Finish

@onready var return_button = $ColorRect/VBoxContainer/Panel/HBoxContainer/ReturnButton
@onready var previous_button = $ColorRect/VBoxContainer/Panel/HBoxContainer/PreviousButton
@onready var next_button = $ColorRect/VBoxContainer/Panel/HBoxContainer/NextButton
@onready var save_button = $ColorRect/VBoxContainer/Panel/HBoxContainer/SaveButton
@onready var continue_button = $ColorRect/VBoxContainer/Panel/HBoxContainer/ContinueButton


func _on_return_button_pressed():
	get_tree().change_scene_to_file("res://interface/main_menu.tscn")

func _on_save_button_pressed():
	var dir_path = "res://saved/characters" if OS.is_debug_build() else "user://characters"
	
	var character_name: String = "default"
	if data.name:
		character_name = data.name
	elif finish.line_edit.text:
		character_name = finish.line_edit.text
	else:
		character_name = "default"

	var path = "%s/%s.tres" % [dir_path, character_name]

	var dir = DirAccess.open("res://saved/")
	if not dir.dir_exists("characters"):
		dir.make_dir("characters")

	var err = ResourceSaver.save(data, path)

	if err != OK:
		push_error("Failed to save character: %s" % err)
	else:
		print("SAVED!")

func _on_continue_button_pressed():
	get_tree().change_scene_to_file("res://locations/game_root.tscn")

func _on_previous_button_pressed():
	creation_tabs.select_previous_available()

func _on_next_button_pressed():
	creation_tabs.select_next_available()


func _ready() -> void:
	return_button.pressed.connect(_on_return_button_pressed)
	save_button.pressed.connect(_on_save_button_pressed)
	continue_button.pressed.connect(_on_continue_button_pressed)
	
	previous_button.pressed.connect(_on_previous_button_pressed)
	next_button.pressed.connect(_on_next_button_pressed)
	
	data = CreatureData.new()
	#data = data.duplicate(true)

	data.level = 12
	
	data.relationships = Relationships.new()
	data.attributes = Attributes.new()
	data.skills = Skills.new()
	data.base_stats = BaseStats.new()
	data.inventory = load("res://resources/creatures/inventory/start_inventory.tres")
	data.equipment = load("res://resources/creatures/equipment/start_equipment.tres")
	data.resistances = Resistances.new()
	data.personality = Personality.new()
	
	data.derived_stats = DerivedStats.new()
	
	data.player_controlled = true

	data.spells_available = []
	data.spells_ready = []
	data.conditions = []
	data.activity_modifiers = []
	data.concentrations = []
	
	for e in data.spells_available:
		print(e, typeof(e), is_instance_valid(e))
	
	$ColorRect/VBoxContainer/CreationTabs/Skills.initialise()
	$ColorRect/VBoxContainer/CreationTabs/Skills.update_all_option_buttons()
