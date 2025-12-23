extends CanvasLayer

func update(character):
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/values/Name.text = character.data.name
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/values/Level.text = "%d" % character.get_final_stat("level")
	#$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/values/MajorArchetype.text = character.get_final_stat("major_archetype")
	#$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/values/MinorArchetype.text = character.get_final_stat("minor_archetype")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/values/Vigour.text = "%d" % character.get_final_stat("vigour")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/values/Size.text = character.get_final_stat("size")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/values/StrengthBonus.text = "%d" % character.get_final_stat("strength_bonus")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/values/Reactions.text = "%d" % character.get_final_stat("max_reactions")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/values/Speed.text = "%d" % character.get_final_stat("max_mp")

	# Attributes
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/VBoxContainer/HBoxContainer/Values/Acuity.text = "%d" % character.get_final_stat("acuity")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/VBoxContainer/HBoxContainer/Values/Brawn.text = "%d" % character.get_final_stat("brawn")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/VBoxContainer/HBoxContainer/Values/Dexterity.text = "%d" % character.get_final_stat("dexterity")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/VBoxContainer/HBoxContainer/Values/Will.text = "%d" % character.get_final_stat("will")

	# Aptitudes
	$Character/ColorRect/HBoxContainer/VBoxContainer/Aptitudes/Agility/Value.text = "%d" % character.get_final_stat("agility")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Aptitudes/Agility/Value.tooltip_text = "16"
	$Character/ColorRect/HBoxContainer/VBoxContainer/Aptitudes/Resolve/Value.text = "%d" % character.get_final_stat("resolve")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Aptitudes/Sense/Value.text = "%d" % character.get_final_stat("sense")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Aptitudes/Stamina/Value.text = "%d" % character.get_final_stat("stamina")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Aptitudes/Offence/Value.text = "%d" % character.get_final_stat("offence")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Aptitudes/MeleeDefence/Value.text = "%d" % character.get_final_stat("melee_defence")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Aptitudes/RangedDefence/Value.text = "%d" % character.get_final_stat("ranged_defence")
	
	# Resistances
	$Character/ColorRect/HBoxContainer/VBoxContainer/Resistances/Physical/Value.text = "%d" % character.get_final_stat("physical")

	# Talents
	$Character/ColorRect/HBoxContainer/VBoxContainer/Talents.text = "Talents: " + ""

	# Conditions
	
	var container = $Character/ColorRect/HBoxContainer/VBoxContainer/HFlowContainer
	for child in container.get_children():
		child.queue_free()

	for condition in character.data.conditions:
		
		var lbl := Label.new()
		lbl.text = condition.name
		lbl.tooltip_text = condition.description
		lbl.mouse_filter = Control.MOUSE_FILTER_STOP
		container.add_child(lbl)
		
func _ready():
	self.layer = 100
