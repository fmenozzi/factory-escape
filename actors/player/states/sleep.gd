extends 'res://actors/player/states/player_state.gd'

const MOVE_ACTIONS := [
    'player_jump',
    'player_dash',
]

var _zzz: Sprite = null
var _lamp: Area2D = null

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    _zzz = player.get_node('Zzz')
    _zzz.visible = true

    player.get_animation_player().play('sleep')

    # If we were previously resting at a lamp, save it to a variable so that we
    # can fade the label back in once we exit the SLEEP state.
    _lamp = null
    if 'lamp' in previous_state_dict:
        _lamp = previous_state_dict['lamp']

func exit(player: Player) -> void:
    _zzz.visible = false

    if _lamp != null:
        _lamp.fade_in_label()

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    for action in MOVE_ACTIONS:
        if event.is_action_pressed(action):
            return {'new_state': Player.State.IDLE}

    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    if player.get_input_direction() != Util.Direction.NONE:
        return {'new_state': Player.State.IDLE}

    return {'new_state': Player.State.NO_CHANGE}
