extends Node

#Dialog
signal dialog_show_message(text)
signal dialog_damage_taken(name, damage)
signal dialog_healing_taken(name, healing)
signal dialog_no_line_of_sight()
signal dialog_out_of_range()
signal dialog_attack_type_selected(attack_type)
signal dialog_selectable_targets(number)
signal dialog_hostile_activity(user, target, user_stat, target_stat, user_roll, target_roll, degree_of_success)

signal crisis_mode_not_active()
signal not_enough_brawn()
#signal not_enough_ap()
#signal not_enough_pp()

signal dialog_start_crisis_mode()
signal dialog_end_crisis_mode()
signal dialog_end_turn()

#Crisis
signal toggle_crisis_mode(creature)
signal start_crisis_mode(creature)
signal end_crisis_mode(creature)
signal end_crisis_turn()
signal turn_ends()
signal toggle_end_turn_button()
signal toggle_crisis_button()
signal weapon_attack(target)
signal on_start_crisis()

signal ai_became_active(creature)
signal ai_became_inactive(creature)

signal request_toggle_crisis(active: bool, creature)
signal crisis_request_denied(reason: String)
signal crisis_request_accepted(active: bool)
signal crisis_state_changed()

#signal active_hostiles_changed(active_creatures)

#AI
signal noticing_check(coordinates)

#signal resolve_damage(name, damage)

#UI
signal open_inventory()
signal update_inventory()
signal update_character_info()
signal drop_item_on_tile(focus_char, last_dragged_item)
signal update_ui_for_char()

#World
signal world_select(tile_coords)
signal world_interact(tile_coords)
signal refresh_reachable_tiles()
signal local_turn_passed()

#Cursors
signal change_cursor(name)
