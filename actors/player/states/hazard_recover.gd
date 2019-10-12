extends "res://scripts/state.gd"

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    player.get_animation_player().play('hazard_recover')

func exit(player: Player) -> void:
    pass

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    # Once the animation is finished, enter the idle state.
    if not player.get_animation_player().is_playing():
        return {'new_state': Player.State.IDLE}

    # Allow exiting early if player tries to move.
    if Util.get_input_direction() != Util.Direction.NONE:
        return {'new_state': Player.State.WALK}

    return {'new_state': Player.State.NO_CHANGE}