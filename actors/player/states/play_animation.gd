extends 'res://actors/player/states/player_state.gd'

export(String) var animation_name := ''

func _get_configuration_warning() -> String:
    if animation_name == '':
        return 'Animation name must not be empty!'

    return ''

func _ready() -> void:
    assert(animation_name != '')

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    player.get_animation_player().play(animation_name)

func exit(player: Player) -> void:
    pass

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    if not player.get_animation_player().is_playing():
        return {'new_state': Player.State.IDLE}

    return {'new_state': Player.State.NO_CHANGE}
