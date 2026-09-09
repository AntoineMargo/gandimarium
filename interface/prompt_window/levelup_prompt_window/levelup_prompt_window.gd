extends PromptWindow
class_name TalentPromptWindow

signal finished(result: Dictionary)

var selected_skill: Enums.Skill
var choice_talents: Array[Talent] = []
var regular_talent: Talent = null

@onready var done_button = $Control/ColorRect/VBoxContainer/HBoxContainer/Button


func _on_exit_pressed() -> void:
	super()
	finished.emit([])


func _on_choice_talent_selected(talent: Talent, choice_index: int) -> void:
	choice_talents[choice_index] = talent


func _on_regular_talent_selected(talent: Talent) -> void:
	regular_talent = talent


func add_choice_talent_button(talent: Talent, button_group: ButtonGroup, index: int) -> void:
	var button = Button.new()
	button.text = talent.name
	button.toggle_mode = true
	button.button_group = button_group

	button.pressed.connect(_on_choice_talent_selected.bind(talent, index))

	list.add_child(button)


func add_regular_talent_button(talent: Talent, button_group: ButtonGroup) -> void:
	var button = Button.new()
	button.text = talent.name
	button.toggle_mode = true
	button.button_group = button_group

	button.pressed.connect(_on_regular_talent_selected.bind(talent))

	list.add_child(button)


func _update_for_char(creature: Creature):
	if not creature:
		return
	for child in list.get_children():
		child.queue_free()

	if creature.data.major_archetype:
		for entry in creature.data.major_archetype.talents_by_level:
			if entry.level == creature.data.applied_level:

				choice_talents.resize(entry.choice_talents.size())
				for i in entry.choice_talents.size():
					var choice = entry.choice_talents[i]

					var choice_talent_button_group = ButtonGroup.new()

					var choice_label = Label.new()
					choice_label.text = "Choose among the following:"
					list.add_child(choice_label)

					for talent in choice.talents:
						add_choice_talent_button(talent, choice_talent_button_group, i)

				var talent_button_group = ButtonGroup.new()
				var regular_talent_label = Label.new()
				regular_talent_label.text = "Choose a talent for this level:"
				list.add_child(regular_talent_label)
				
				for talent in creature.data.talent_pool:
					add_regular_talent_button(talent, talent_button_group)

	#if creature.data.applied_level % 2 == 0:
	var hbox = HBoxContainer.new()
	list.add_child(hbox)
	var new_skill_label = Label.new()
	new_skill_label.text = "Choose a new skill:"
	hbox.add_child(new_skill_label)
	var skill_option_button = OptionButton.new()
	setup_option_button(skill_option_button, creature)
	hbox.add_child(skill_option_button)
	skill_option_button.item_selected.connect(_on_option_button_item_selected.bind(skill_option_button))


func setup_option_button(button: OptionButton, creature: Creature) -> void:
	button.clear()

	var first_valid_index: int = -1

	for skill in creature.data.base_stats.skills:
		var skill_name: String = Enums.Skill.keys()[skill].to_lower()
		button.add_item(skill_name)
		button.set_item_metadata(button.item_count - 1, skill)

		if creature.data.base_stats.get_skill(skill) > 0:
			button.set_item_disabled(button.item_count - 1, true)
		elif first_valid_index == -1:
			first_valid_index = button.item_count - 1

	if first_valid_index != -1:
		button.select(first_valid_index)


func _on_option_button_item_selected(index: int, button: OptionButton) -> void:
	selected_skill = button.get_item_metadata(index)


func finish() -> void:
	#if not regular_talent:
		#return

	#for talent in choice_talents:
		#if not talent:
			#return
	
	finished.emit({
	"regular_talent": regular_talent,
	"choice_talents": choice_talents,
	"selected_skill": selected_skill
	})


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	selected_skill = Enums.Skill.ARCANE
	regular_talent = null
	choice_talents.clear()
	done_button.pressed.connect(finish)
	super()
	_update_for_char(Global.selected_char)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
