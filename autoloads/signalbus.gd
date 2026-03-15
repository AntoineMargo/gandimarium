extends Node
@warning_ignore_start("unused_signal")

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

#Time
signal time_changed(days, hours, minutes, seconds)
signal time_skipped(hours)
signal hour_change(n)

#Crisis
signal toggle_crisis_mode(creature)
signal start_crisis_mode(creature)
signal end_crisis_mode(creature)
signal end_player_turn()
signal turn_ends()
signal toggle_end_turn_button()
signal toggle_crisis_button()
signal weapon_attack(target)
signal on_start_crisis()
signal add_to_initiative(creature)

signal ai_became_active(creature)
signal ai_became_inactive(creature)

signal request_toggle_crisis(active: bool, creature)
signal crisis_request_denied(reason: String)
signal crisis_request_accepted(active: bool)
signal crisis_state_changed()

#signal active_hostiles_changed(active_creatures)

#AI
signal noticing_check(coordinates)
signal sight_check(pos)
signal stop_all_movement()
#signal resolve_damage(name, damage)

#UI
signal open_inventory()
signal update_inventory()
signal update_container()
signal update_character_info()
signal drop_item_on_tile(character)
signal update_ui_for_char()
signal end_crisis_turn()

#World
signal simple_interact()
signal complex_interact()
#signal refresh_reachable_tiles()
#signal local_turn_passed()
signal clear_path_preview()
signal world_ready()
signal world_quit()

#Cursors
signal change_cursor(name)
