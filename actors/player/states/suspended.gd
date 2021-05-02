extends 'res://actors/player/states/player_state.gd'

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    player.get_animation_player().play('fall')
    player.get_sound_manager().set_all_muted(true)

func exit(player: Player) -> void:
    player.get_sound_manager().set_all_muted(false)

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    return {'new_state': Player.State.NO_CHANGE}
