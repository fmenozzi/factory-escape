extends 'res://actors/player/states/player_state.gd'

export(String) var animation_name := ''
export(PlayerSoundManager.Sounds) var sound := -1

func _get_configuration_warning() -> String:
    if animation_name == '' or sound == -1:
        return 'Must provide both animation name and sound!'

    return ''

func _ready() -> void:
    assert(animation_name != '' and sound != -1)

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    player.get_animation_player().play(animation_name)
    player.get_sound_manager().play(sound)

func exit(player: Player) -> void:
    pass

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    # Wait for animation to finish before proceeding.
    if not player.get_animation_player().is_playing():
        return {'new_state': Player.State.IDLE}

    return {'new_state': Player.State.NO_CHANGE}
