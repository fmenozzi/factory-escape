extends 'res://actors/player/states/state.gd'

const MOVE_ACTIONS := [
    'player_jump',
    'player_dash',
]

var _lamp: Area2D = null

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    # Play pre-rest animation and queue up main rest animation when entering the
    # rest state. This is a workaround to the fact that I cannot loop only part
    # of an animation in Godot, as far as I know.
    var animation_player := player.get_animation_player()
    animation_player.play('pre_rest')
    animation_player.queue('rest')

    assert(previous_state_dict.has('lamp'))
    assert(previous_state_dict['lamp'] != null)
    _lamp = previous_state_dict['lamp']

    # Turn player to face lamp.
    player.set_direction(Util.direction(player, _lamp))

    # Fade lamp's label out.
    _lamp.fade_out_label()

func exit(player: Player) -> void:
    player.get_animation_player().clear_queue()

    # Fade lamp's label back in.
    _lamp.fade_in_label()

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    for action in MOVE_ACTIONS:
        if event.is_action_pressed(action):
            return {'new_state': Player.State.IDLE}

    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    if Util.get_input_direction() != Util.Direction.NONE:
        return {'new_state': Player.State.IDLE}

    return {'new_state': Player.State.NO_CHANGE}