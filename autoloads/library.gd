extends Node

var _maps = {
	
}

var _items = {
	"ar_heavy": "res://resources/items/armours/ar_heavy.tres",
	"ar_light": "res://resources/items/armours/ar_light.tres",
	
	"wpn_fist": "res://resources/items/weapons/fist/wpn_fist.tres",
	"wpn_pollaxe": "res://resources/items/weapons/pollaxe/pollaxe.tres",
	"wpn_longsword": "res://resources/items/weapons/longsword/longsword.tres",
	"wpn_bow": "res://resources/items/weapons/bow/bow.tres",
	#"wpn_battle_axe": "res://resources/items/weapons/wpn_battle_axe.tres",
	#"wpn_bow": "res://resources/items/weapons/wpn_bow.tres",
	#"wpn_dagger": "res://resources/items/weapons/wpn_dagger.tres",
	#"wpn_estoc": "res://resources/items/weapons/wpn_estoc.tres",
	#"wpn_falchion": "res://resources/items/weapons/wpn_falchion.tres",
	#"wpn_greatsword": "res://resources/items/weapons/wpn_greatsword.tres",
	#"wpn_great_axe": "res://resources/items/weapons/wpn_great_axe.tres",
	#"wpn_hand_axe": "res://resources/items/weapons/wpn_hand_axe.tres",
	#"wpn_knife": "res://resources/items/weapons/wpn_knife.tres",
	#"wpn_large_shield": "res://resources/items/weapons/wpn_large_shield.tres",
	#"wpn_light_shield": "res://resources/items/weapons/wpn_light_shield.tres",
	#"wpn_longspear": "res://resources/items/weapons/wpn_longspear.tres",
	#"wpn_longsword": "res://resources/items/weapons/wpn_longsword.tres",
	#"wpn_lucerne": "res://resources/items/weapons/wpn_lucerne.tres",
	#"wpn_mace": "res://resources/items/weapons/wpn_mace.tres",
	#"wpn_medium_shield": "res://resources/items/weapons/wpn_medium_shield.tres",
	#"wpn_partisan": "res://resources/items/weapons/wpn_partisan.tres",
	#"wpn_quarterstaff": "res://resources/items/weapons/wpn_quarterstaff.tres",
	#"wpn_saber": "res://resources/items/weapons/wpn_saber.tres",
	#"wpn_shortspear": "res://resources/items/weapons/wpn_shortspear.tres",
	#"wpn_shortsword": "res://resources/items/weapons/wpn_shortsword.tres",
	#"wpn_warhammer": "res://resources/items/weapons/wpn_warhammer.tres",
}

var _activities = {
	"aura_condition": "res://resources/activities/aura_condition.tres",
	"aura_damage": "res://resources/activities/aura_damage.tres",
	"firebolt": "res://resources/activities/firebolt.tres",
	"firebolt2A": "res://resources/activities/firebolt2A.tres",
	"firebolt3A": "res://resources/activities/firebolt3A.tres",
	"firebolts": "res://resources/activities/firebolts.tres",
	"move": "res://resources/activities/move.tres",
	"weapon_attack": "res://resources/activities/wpn_attack.tres"
}

var _talents = {
	"paragon_vigour": "res://resources/talents/paragon_vigour.tres"
}

var _archetypes = {
	"paragon": "res://resources/archetypes/paragon/paragon.tres"
}

var _abilities = {
	"degrade_defences": "res://resources/abilities/degrade_defences.tres",
	"firebolt": "res://resources/abilities/firebolt.tres",
	"fireray": "res://resources/abilities/fireray.tres"
}

var _dmg_patterns = {
	"default": "res://resources/damage_patterns/default.tres",
	"slash": "res://resources/damage_patterns/slash.tres",
	"pierce": "res://resources/damage_patterns/pierce.tres",
	"crush" : "res://resources/damage_patterns/crush.tres",
	"throw": "res://resources/damage_patterns/throw.tres"
}

var _char_sprites = {
	
}

func get_map(id: String) -> Resource:
	return _get_from(_maps, id)

func get_item(id: String) -> Resource:
	return _get_from(_items, id)

func get_activity(id: String) -> Resource:
	return _get_from(_activities, id)

func get_ability(id: String) -> Resource:
	return _get_from(_abilities, id)

func get_talent(id: String) -> Resource:
	return _get_from(_talents, id)

func get_archetype(id: String) -> Resource:
	return _get_from(_archetypes, id)

func get_dmg_pattern(id: String) -> Resource:
	return _get_from(_dmg_patterns, id)

func get_char_sprite(id: String) -> Resource:
	return _get_from(_char_sprites, id)

func _get_from(dict: Dictionary, id: String) -> Resource:
	if dict.has(id):
		var ref = dict[id]
		if ref is String:
			dict[id] = load(ref)
		return dict[id]
	else:
		return null
