extends CanvasLayer

func update(character):
	
	# Basics
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/values/Name.text = character.data.name
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/values/Level.text = "%d" % character.get_stat("level")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/values/MajorArchetype.text = character.get_stat("major_archetype")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/values/MinorArchetype.text = character.get_stat("minor_archetype")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/values/Vigour.text = "%d" % character.get_stat("vigour")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/values/Size.text = character.get_stat("size")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/values/StrengthBonus.text = "%d" % character.get_stat("strength_bonus")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/values/Reactions.text = "%d" % character.get_stat("max_reactions")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/values/Speed.text = "%d" % character.get_stat("max_mp")

	# Attributes
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/VBoxContainer/HBoxContainer/Values/Acuity.text = "%d" % character.get_stat("acuity")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/VBoxContainer/HBoxContainer/Values/Brawn.text = "%d" % character.get_stat("brawn")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/VBoxContainer/HBoxContainer/Values/Dexterity.text = "%d" % character.get_stat("dexterity")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/VBoxContainer/HBoxContainer/Values/Will.text = "%d" % character.get_stat("will")

	# Aptitudes
	$Character/ColorRect/HBoxContainer/VBoxContainer/Aptitudes/Agility/Value.text = "%d" % character.get_stat("agility")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Aptitudes/Resolve/Value.text = "%d" % character.get_stat("resolve")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Aptitudes/Sense/Value.text = "%d" % character.get_stat("sense")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Aptitudes/Stamina/Value.text = "%d" % character.get_stat("stamina")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Aptitudes/Offence/Value.text = "%d" % character.get_stat("offence")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Aptitudes/MeleeDefence/Value.text = "%d" % character.get_stat("melee_defence")
	$Character/ColorRect/HBoxContainer/VBoxContainer/Aptitudes/RangedDefence/Value.text = "%d" % character.get_stat("ranged_defence")
	
	# Resistances
	$Character/ColorRect/HBoxContainer/VBoxContainer/Resistances/Physical/Value.text = "%d" % character.get_stat("physical")

	# Talents
	$Character/ColorRect/HBoxContainer/VBoxContainer/Talents.text = "Talents: " + ""

	# Conditions
	$Character/ColorRect/HBoxContainer/VBoxContainer/Conditions.text = "Conditions: " + ""
