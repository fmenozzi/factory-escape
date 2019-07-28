extends "res://scripts/state.gd"

# Reference to the player. Needed for draw_grapple_rope() and
# clear_grapple_rope(), which are called from the animation player.
var _player: Player = null

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    _player = player

    if player.is_on_ground():
        player.get_animation_player().play('grapple_launch_long')
    else:
        player.get_animation_player().play('grapple_launch_short')

    # Make the player face the grapple point.
    var grapple_point_pos := \
        player.get_next_grapple_point().get_attachment_pos()
    var grapple_direction := sign((grapple_point_pos - player.global_position).x)
    player.set_player_direction(grapple_direction)

func exit(player: Player) -> void:
    pass

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    return {'new_state': player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    # Once we finish the grapple animation, switch to the actual grapple state.
    if not player.get_animation_player().is_playing():
        return {'new_state': player.State.GRAPPLE}

    return {'new_state': player.State.NO_CHANGE}

func draw_grapple_rope() -> void:
    var grapple_point_pos := _player.get_next_grapple_point().get_attachment_pos()

    var grapple_rope := _player.get_grapple_rope()
    grapple_rope.add_point(Vector2.ZERO)
    grapple_rope.add_point(grapple_point_pos - grapple_rope.global_position)

func clear_grapple_rope() -> void:
    _player.get_grapple_rope().clear_points()
