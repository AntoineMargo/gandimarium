extends Panel

var root = null

var max_skill: int = 0
var available_values: Array[int] = []
var assigned_values: Dictionary = {}

@onready var skill_buttons = {
	"arcane": $VBoxContainer/HBoxContainer/VBoxContainer/Arcane/OptionButton,
	"artistry": $VBoxContainer/HBoxContainer/VBoxContainer/Artistry/OptionButton,
	"society": $VBoxContainer/HBoxContainer/VBoxContainer/Society/OptionButton,
	"craftsmanship": $VBoxContainer/HBoxContainer/VBoxContainer/Craftsmanship/OptionButton,
	"deception": $VBoxContainer/HBoxContainer/VBoxContainer/Deception/OptionButton,
	"history" : $VBoxContainer/HBoxContainer/VBoxContainer/History/OptionButton,
	"linguistics" : $VBoxContainer/HBoxContainer/VBoxContainer/Linguistics/OptionButton,
	"mechanics" : $VBoxContainer/HBoxContainer/VBoxContainer/Mechanics/OptionButton,
	"medicine" : $VBoxContainer/HBoxContainer/VBoxContainer/Medicine/OptionButton,
	"nature" : $VBoxContainer/HBoxContainer/VBoxContainer/Nature/OptionButton,
	"persuasion" : $VBoxContainer/HBoxContainer/VBoxContainer/Persuasion/OptionButton,
	"thievery" : $VBoxContainer/HBoxContainer/VBoxContainer/Thievery/OptionButton,
	"stealth" : $VBoxContainer/HBoxContainer/VBoxContainer/Stealth/OptionButton
	}
	
@onready var points_left_label = $VBoxContainer/HBoxContainer2/VBoxContainer/PointsLeft

func setup_option_button(button: OptionButton, values: Array[int], current_value):
	button.clear()

	button.add_item("—", 0)

	for v in values:
		button.add_item(str(v), v)

	var idx = button.get_item_index(current_value)
	if idx != 0:
		button.select(idx)

func get_remaining_values() -> Array[int]:
	var used: Array[int] = []

	for v in assigned_values.values():
		if v != 0:
			used.append(v)

	var remaining: Array[int] = []

	for v in available_values:
		if v not in used:
			remaining.append(v)

	return remaining

func _on_value_selected(index: int, skill: String):
	var button = skill_buttons[skill]
	var value = button.get_item_id(index)

	assigned_values[skill] = value
	update_all_option_buttons()

func update_all_option_buttons():
	var remaining = get_remaining_values()

	for skill in skill_buttons:
		var button = skill_buttons[skill]
		var current_value = assigned_values[skill]

		var values = remaining.duplicate()

		if current_value != 0:
			values.append(current_value)

		values.sort()

		setup_option_button(button, values, current_value)

	update_points_left_label(remaining)
	export_skills_to_data()

func update_points_left_label(values):
	var text = "Starting skill ranks left: "
	var values_nbr = values.size()
	if values_nbr == 0:
		text += "None"
		points_left_label.text = text
		return
	else:
		for i in range(values_nbr - 1):
			text += "%d, " % [values[i]]
		text += "%d" % [values[values_nbr - 1]]
		points_left_label.text = text

func export_skills_to_data():
	var stats = root.data.skills
	
	stats.arcane = assigned_values["arcane"]
	stats.artistry = assigned_values["artistry"]
	stats.society = assigned_values["society"]
	stats.craftsmanship = assigned_values["craftsmanship"]
	stats.deception = assigned_values["deception"]
	stats.history = assigned_values["history"]
	stats.linguistics = assigned_values["linguistics"]
	stats.mechanics = assigned_values["mechanics"]
	stats.medicine = assigned_values["medicine"]
	stats.nature = assigned_values["nature"]
	stats.persuasion = assigned_values["persuasion"]
	stats.thievery = assigned_values["thievery"]
	stats.stealth = assigned_values["stealth"]

func initialise():
	max_skill = root.data.attributes.acuity

	available_values.clear()
	for i in range(1, max_skill + 1):
		available_values.append(i)

	for skill in skill_buttons.keys():
		assigned_values[skill] = 0
	
	update_all_option_buttons()

func connect_signals():
	for skill in skill_buttons:
		var button = skill_buttons[skill]
		button.item_selected.connect(_on_value_selected.bind(skill))

func _ready() -> void:
	root = $"../../../.."
	connect_signals()
