extends CanvasLayer

@onready var control = get_node_or_null("Character")

func get_archetype_name(archetype) -> String:
	if archetype:
		match archetype.type:
			Enums.Archetype.NONE:
				return "None"
			Enums.Archetype.SCHOLASTIC_MAGE:
				return "Scholastic Mage"
			Enums.Archetype.ASPECTED_MAGE:
				return "Aspected Mage"
			Enums.Archetype.PRIMAL_MAGE:
				return "Primal Mage"
			Enums.Archetype.BATTLE_MAGE:
				return "Battle Mage"
			Enums.Archetype.PARAGON:
				return "Paragon"
			Enums.Archetype.LEGION:
				return "Legion"
	return "None"


func update(character):
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/values/Name.text = character.data.name
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/values/Level.text = "%d" % character.get_final_stat("level")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/values/MajorArchetype.text = get_archetype_name(character.data.major_archetype) 
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/values/MinorArchetype.text = get_archetype_name(character.data.minor_archetype) 
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/values/Vigour.text = "%d" % character.get_final_stat("vigour")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/values/Size.text = character.get_final_stat("size")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/values/StrengthBonus.text = "%d" % character.get_final_stat("strength_bonus")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/values/Reactions.text = "%d" % character.get_final_stat("max_reactions")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/values/Speed.text = "%d" % character.get_final_stat("max_mp")

	# Attributes
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/VBoxContainer/HBoxContainer/Values/Acuity.text = "%d" % character.get_final_stat("acuity")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/VBoxContainer/HBoxContainer/Values/Brawn.text = "%d" % character.get_final_stat("brawn")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/VBoxContainer/HBoxContainer/Values/Dexterity.text = "%d" % character.get_final_stat("dexterity")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/VBoxContainer/HBoxContainer/Values/Resolve.text = "%d" % character.get_final_stat("resolve")

	# Aptitudes
	$Character/ColorRect/HBoxContainer/VBoxContainer/Aptitudes/Agility/Value.text = "%d" % character.get_final_stat("agility")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Aptitudes/Agility/Value.tooltip_text = "16"
	$Character/ColorRect/HBoxContainer/VBoxContainer/Aptitudes/Will/Value.text = "%d" % character.get_final_stat("will")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Aptitudes/Sense/Value.text = "%d" % character.get_final_stat("sense")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Aptitudes/Stamina/Value.text = "%d" % character.get_final_stat("stamina")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Aptitudes/Offence/Value.text = "%d" % character.get_final_stat("offence")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Aptitudes/MeleeDefence/Value.text = "%d" % character.get_final_stat("melee_defence")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Aptitudes/RangedDefence/Value.text = "%d" % character.get_final_stat("ranged_defence")
	
	# Resistances
	$Character/ColorRect/HBoxContainer/VBoxContainer/Resistances/Physical/Value.text = "%d" % character.get_final_stat("physical")

	# Talents
	$Character/ColorRect/HBoxContainer/VBoxContainer/Talents.text = "Talents: " + ""

	var tal_container = $Character/ColorRect/HBoxContainer/VBoxContainer/TalentContainer
	for child in tal_container.get_children():
		child.queue_free()

	for talent in character.data.talents:
		
		#if talent.is_visible:
		var lbl := Label.new()
		lbl.text = talent.name
		lbl.tooltip_text = talent.description
		lbl.mouse_filter = Control.MOUSE_FILTER_STOP
		tal_container.add_child(lbl)

	# Conditions
	
	var cond_container = $Character/ColorRect/HBoxContainer/VBoxContainer/ConditionContainer
	for child in cond_container.get_children():
		child.queue_free()

	for condition in character.data.conditions:
		
		if condition.is_visible:
			var lbl := Label.new()
			lbl.text = condition.name
			lbl.tooltip_text = condition.description
			lbl.mouse_filter = Control.MOUSE_FILTER_STOP
			cond_container.add_child(lbl)

func _on_exit_pressed() -> void:
	Global.character_window.visible = false

func _ready():
	self.layer = 100
	$Character/ColorRect/HBoxContainer/VBoxContainer/TopBar/ExitButton.pressed.connect(_on_exit_pressed)
