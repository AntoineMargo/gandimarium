extends Effect
class_name AddSpellEffect

@export var spells: Array[Spell] = []

func apply(source, target, degree: int) -> void:
	for spell in spells:
		var new_spell = spell.duplicate()
		if target.has_method("add_ready_spell"):
			target.add_ready_spell(new_spell)
