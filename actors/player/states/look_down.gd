extends 'res://actors/player/states/player_state.gd'

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    player.get_animation_player().play('look_down')

    player.get_camera().pan_down()

func exit(player: Player) -> void:
    player.get_camera().return_from_pan()

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    if event.is_action_released('player_look_down'):
        return {'new_state': Player.State.IDLE}

    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    return {'new_state': Player.State.NO_CHANGE}
