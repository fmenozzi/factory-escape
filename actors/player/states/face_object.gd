extends 'res://actors/player/states/player_state.gd'

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    assert('object_to_face' in previous_state_dict)
    var object_to_face: Node2D = previous_state_dict['object_to_face']
    player.set_direction(Util.direction(player, object_to_face))

func exit(player: Player) -> void:
    pass

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    # All the work for this state was done in enter(), so immediately transition
    # to the idle state.
    return {'new_state': Player.State.IDLE}
