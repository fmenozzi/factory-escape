extends 'res://actors/player/states/player_state.gd'

var _stopping_point: Position2D
var _direction_to_stopping_point: int = Util.Direction.NONE

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    # Reset player velocity.
    player.velocity = Vector2.ZERO

    # Play walk animation.
    player.get_animation_player().play('walk')

    # Get stopping point from previous state.
    assert('stopping_point' in previous_state_dict)
    _stopping_point = previous_state_dict['stopping_point']
    assert(_stopping_point != null)

    # Turn player to face stopping point.
    _direction_to_stopping_point = Util.direction(player, _stopping_point)
    player.set_direction(_direction_to_stopping_point)

func exit(player: Player) -> void:
    player.emit_signal('player_reached_walk_to_point')

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    # Switch to idle once we hit the stopping point.
    match _direction_to_stopping_point:
        Util.Direction.LEFT:
            if player.global_position.x <= _stopping_point.global_position.x:
                player.global_position.x = _stopping_point.global_position.x
                return {'new_state': Player.State.IDLE}

        Util.Direction.RIGHT:
            if player.global_position.x >= _stopping_point.global_position.x:
                player.global_position.x = _stopping_point.global_position.x
                return {'new_state': Player.State.IDLE}

        Util.Direction.NONE:
            return {'new_state': Player.State.IDLE}

    # If we've somehow walked off a platform, start falling.
    if player.is_in_air():
        return {'new_state': Player.State.FALL}

    # If we've somehow rammed into a wall, switch to idle.
    if player.is_on_wall():
        return {'new_state': Player.State.IDLE}

    # Move to stopping point. Add in sufficient downward movement so that
    # is_on_floor() detects collisions with the floor and doesn't erroneously
    # report that we're in the air.
    var speed := player.get_physics_manager().get_movement_speed()
    player.move(Vector2(_direction_to_stopping_point * speed, 10))

    return {'new_state': Player.State.NO_CHANGE}
