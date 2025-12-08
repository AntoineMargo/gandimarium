extends CanvasLayer

func update(character):
	
	# Basics
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/values/Name.text = character.data.name
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/values/Level.text = "%d" % character.data.level
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/values/MajorArchetype.text = character.data.major_archetype
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/values/MinorArchetype.text = character.data.minor_archetype
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/values/Vigour.text = "%d" % character.data.vigour
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/values/Size.text = character.data.final_size
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/values/StrengthBonus.text = "%d" % character.data.strength_bonus
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/values/Reactions.text = "%d" % character.data.max_reactions
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/values/Speed.text = "%d" % character.data.max_mp

	# Attributes
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/VBoxContainer/HBoxContainer/Values/Acuity.text = "%d" % character.data.acuity
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/VBoxContainer/HBoxContainer/Values/Brawn.text = "%d" % character.data.brawn
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/VBoxContainer/HBoxContainer/Values/Dexterity.text = "%d" % character.data.dexterity
	$Character/ColorRect/HBoxContainer/VBoxContainer/Basics/VBoxContainer/HBoxContainer/Values/Will.text = "%d" % character.data.will

	# Aptitudes
	$Character/ColorRect/HBoxContainer/VBoxContainer/Aptitudes/Agility/Value.text = "%d" % character.data.agility
	$Character/ColorRect/HBoxContainer/VBoxContainer/Aptitudes/Resolve/Value.text = "%d" % character.data.resolve
	$Character/ColorRect/HBoxContainer/VBoxContainer/Aptitudes/Sense/Value.text = "%d" % character.data.sense
	$Character/ColorRect/HBoxContainer/VBoxContainer/Aptitudes/Stamina/Value.text = "%d" % character.data.stamina
	$Character/ColorRect/HBoxContainer/VBoxContainer/Aptitudes/Offence/Value.text = "%d" % character.data.offence
	$Character/ColorRect/HBoxContainer/VBoxContainer/Aptitudes/MeleeDefence/Value.text = "%d" % character.data.melee_defence
	$Character/ColorRect/HBoxContainer/VBoxContainer/Aptitudes/RangedDefence/Value.text = "%d" % character.data.ranged_defence
	
	# Resistances
	$Character/ColorRect/HBoxContainer/VBoxContainer/Resistances/Physical/Value.text = "%d" % character.data.resistances.physical

	# Talents
	$Character/ColorRect/HBoxContainer/VBoxContainer/Talents.text = "Talents: " + ""

	# Conditions
	$Character/ColorRect/HBoxContainer/VBoxContainer/Conditions.text = "Conditions: " + ""
