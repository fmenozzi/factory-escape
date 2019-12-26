extends 'res://actors/player/states/state.gd'

const MOVE_ACTIONS := [
    'player_jump',
    'player_dash',
    'player_interact',
]

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    player.get_animation_player().play('rest')

func exit(player: Player) -> void:
    pass

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    for action in MOVE_ACTIONS:
        if event.is_action_pressed(action):
            return {'new_state': Player.State.IDLE}

    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    if Util.get_input_direction() != Util.Direction.NONE:
        return {'new_state': Player.State.IDLE}

    return {'new_state': Player.State.NO_CHANGE}