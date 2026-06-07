extends Panel

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

func _on_update_character_info():
	update(Global.selected_char)

func update(character):
	%Name.text = character.data.name
	%Level.text = "%d" % character.get_final_stat("level")
	%MajorArchetype.text = get_archetype_name(character.data.major_archetype) 
	%MinorArchetype.text = get_archetype_name(character.data.minor_archetype) 
	%Vigour.text = "%d" % character.get_final_stat("vigour")
	%Size.text = character.get_final_stat("size")
	%StrengthBonus.text = "%d" % character.get_final_stat("strength_bonus")
	%Reactions.text = "%d" % character.get_final_stat("max_reactions")
	%Speed.text = "%d" % character.get_final_stat("max_mp")

	# Attributes
	%Acuity.text = "%d" % character.get_final_stat("acuity")
	%Brawn.text = "%d" % character.get_final_stat("brawn")
	%Dexterity.text = "%d" % character.get_final_stat("dexterity")
	%Resolve.text = "%d" % character.get_final_stat("resolve")

	# Aptitudes
	$VBoxContainer/Aptitudes/Agility/Value.text = "%d" % character.get_final_stat("agility")
	$VBoxContainer/Aptitudes/Will/Value.text = "%d" % character.get_final_stat("will")
	$VBoxContainer/Aptitudes/Sense/Value.text = "%d" % character.get_final_stat("sense")
	$VBoxContainer/Aptitudes/Stamina/Value.text = "%d" % character.get_final_stat("stamina")
	$VBoxContainer/Aptitudes/Offence/Value.text = "%d" % character.get_final_stat("offence")
	$VBoxContainer/Aptitudes/MeleeDefence/Value.text = "%d" % character.get_final_stat("melee_defence")
	$VBoxContainer/Aptitudes/RangedDefence/Value.text = "%d" % character.get_final_stat("ranged_defence")
	
	#$Character/ColorRect/HBoxContainer/VBoxContainer/Aptitudes/Agility/Value.tooltip_text = "16"
	
	# Resistances
	$VBoxContainer/Resistances/Physical/Value.text = "%d" % character.get_final_stat("physical")

	# Talents
	$VBoxContainer/Talents.text = "Talents: " + ""

	var tal_container = $VBoxContainer/TalentContainer
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
	
	var cond_container = $VBoxContainer/ConditionContainer
	for child in cond_container.get_children():
		child.queue_free()

	for condition in character.data.conditions:
		
		if condition.is_visible:
			var lbl := Label.new()
			lbl.text = condition.name
			lbl.tooltip_text = condition.description
			lbl.mouse_filter = Control.MOUSE_FILTER_STOP
			cond_container.add_child(lbl)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.update_character_info.connect(_on_update_character_info)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
