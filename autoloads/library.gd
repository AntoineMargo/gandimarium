extends Node

var _maps = {
	
}

var _items = {
	"ar_heavy": "res://items/armours/ar_heavy.tres",
	"ar_light": "res://items/armours/ar_light.tres",
	"wpn_battle_axe": "res://items/weapons/wpn_battle_axe.tres",
	"wpn_bow": "res://items/weapons/wpn_bow.tres",
	"wpn_dagger": "res://items/weapons/wpn_dagger.tres",
	"wpn_estoc": "res://items/weapons/wpn_estoc.tres",
	"wpn_falchion": "res://items/weapons/wpn_falchion.tres",
	"wpn_fist": "res://items/weapons/wpn_fist.tres",
	"wpn_greatsword": "res://items/weapons/wpn_greatsword.tres",
	"wpn_great_axe": "res://items/weapons/wpn_great_axe.tres",
	"wpn_hand_axe": "res://items/weapons/wpn_hand_axe.tres",
	"wpn_knife": "res://items/weapons/wpn_knife.tres",
	"wpn_large_shield": "res://items/weapons/wpn_large_shield.tres",
	"wpn_light_shield": "res://items/weapons/wpn_light_shield.tres",
	"wpn_longspear": "res://items/weapons/wpn_longspear.tres",
	"wpn_longsword": "res://items/weapons/wpn_longsword.tres",
	"wpn_lucerne": "res://items/weapons/wpn_lucerne.tres",
	"wpn_mace": "res://items/weapons/wpn_mace.tres",
	"wpn_medium_shield": "res://items/weapons/wpn_medium_shield.tres",
	"wpn_partisan": "res://items/weapons/wpn_partisan.tres",
	"wpn_poleaxe": "res://items/weapons/wpn_poleaxe.tres",
	"wpn_quarterstaff": "res://items/weapons/wpn_quarterstaff.tres",
	"wpn_saber": "res://items/weapons/wpn_saber.tres",
	"wpn_shortspear": "res://items/weapons/wpn_shortspear.tres",
	"wpn_shortsword": "res://items/weapons/wpn_shortsword.tres",
	"wpn_warhammer": "res://items/weapons/wpn_warhammer.tres",
}

var _activities = {
	"aura_condition": "res://activities/aura_condition.tres",
	"aura_damage": "res://activities/aura_damage.tres",
	"firebolt": "res://activities/firebolt.tres",
	"firebolt2A": "res://activities/firebolt2A.tres",
	"firebolt3A": "res://activities/firebolt3A.tres",
	"firebolts": "res://activities/firebolts.tres",
	"move": "res://activities/move.tres",
	"weapon_attack": "res://activities/wpn_attack.tres"
}

var _abilities = {
	"degrade_defences": "res://abilities/degrade_defences.tres",
	"firebolt": "res://abilities/firebolt.tres",
	"fireray": "res://abilities/fireray.tres"
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
