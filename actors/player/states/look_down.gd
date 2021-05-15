extends 'res://actors/player/states/player_state.gd'

var _entered_from_controller: bool

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    assert('entered_from_controller' in previous_state_dict)
    _entered_from_controller = previous_state_dict['entered_from_controller']

    player.get_animation_player().play('look_down')

    player.get_camera().pan_down()

func exit(player: Player) -> void:
    player.get_camera().return_from_pan()

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    if event.is_action_released('player_look_down_controller'):
        if _entered_from_controller:
            return {'new_state': Player.State.IDLE}

    if event.is_action_released('player_look_down_keyboard'):
        if not _entered_from_controller:
            return {'new_state': Player.State.IDLE}

    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    # Apply slight downward movement. This is important mostly for ensuring that
    # move_and_slide() is called on every frame, which updates collisions. This
    # allows us to e.g. idle next to a wall (without pressing into it) and have
    # is_on_wall() correctly report that we're NOT on a wall, which is important
    # for not triggering wall slide when jumping up from idling next to a wall.
    player.move(Vector2(0, player.get_slight_downward_move()))

    # Transition to fall if we're no longer on the ground (e.g. conveyor belt or
    # collapsable platform).
    if player.is_in_air():
        return {'new_state': Player.State.FALL}

    return {'new_state': Player.State.NO_CHANGE}
