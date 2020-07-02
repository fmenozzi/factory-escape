extends 'res://actors/player/states/player_state.gd'

# Reference to the player. Needed for draw_grapple_rope() and
# clear_grapple_rope(), which are called from the animation player.
var _player: Player = null

var _grapple_point: GrapplePoint = null

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    _player = player

    _grapple_point = previous_state_dict['grapple_point']
    assert(_grapple_point != null)

    # This grapple point is no longer available for the duration of the grapple.
    _grapple_point.set_available(false)

    if player.is_on_ground():
        player.get_animation_player().play('grapple_launch_long')
    else:
        player.get_animation_player().play('grapple_launch_short')

    # Make the player face the grapple point.
    var grapple_point_pos := _grapple_point.get_attachment_pos()
    var grapple_direction := Util.direction(player, grapple_point_pos)
    player.set_direction(grapple_direction)

func exit(player: Player) -> void:
    _grapple_point = null

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    # Once we finish the grapple animation, switch to the actual grapple swing
    # state.
    if not player.get_animation_player().is_playing():
        return {
            'new_state': Player.State.NEXT_STATE_IN_SEQUENCE,
            'grapple_point': _grapple_point,
        }

    return {'new_state': Player.State.NO_CHANGE}

func draw_grapple_rope() -> void:
    var grapple_point_pos := _grapple_point.get_attachment_pos().global_position

    var grapple_rope := _player.get_grapple_rope()
    grapple_rope.add_point(Vector2.ZERO)
    grapple_rope.add_point(grapple_point_pos - grapple_rope.global_position)

    var grapple_hook: Sprite = _player.get_grapple_hook()
    grapple_hook.position = grapple_point_pos - grapple_hook.global_position
    grapple_hook.rotation = grapple_hook.position.angle()
    grapple_hook.visible = true

func clear_grapple_rope() -> void:
    _player.get_grapple_rope().clear_points()

    var grapple_hook = _player.get_grapple_hook()
    grapple_hook.visible = false
    grapple_hook.position = Vector2.ZERO

