extends 'res://actors/player/states/state.gd'

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    player.get_animation_player().play('hazard_hit')

func exit(player: Player) -> void:
    pass

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    return {'new_state': Player.State.NO_CHANGE}