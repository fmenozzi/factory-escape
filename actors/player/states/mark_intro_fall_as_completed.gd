extends 'res://actors/player/states/player_state.gd'

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    player.save_manager.has_completed_intro_fall_sequence = true
    player.save_manager.last_saved_global_position = player.global_position
    player.save_manager.last_saved_direction_to_lamp = player.get_direction()

    player.get_health_pack_manager().update_saved_num_health_packs()

func exit(player: Player) -> void:
    player.emit_signal('player_finished_intro_fall')

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    return {'new_state': Player.State.IDLE}
