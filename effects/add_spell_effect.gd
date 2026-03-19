extends Effect
class_name AddSpellEffect

@export var spells: Array[Spell] = []

func apply(_source, target, _degree: int = 2) -> void:
	for spell in spells:
		var new_spell = spell.duplicate()
		if target.has_method("add_ready_spell"):
			target.add_ready_spell(new_spell)
