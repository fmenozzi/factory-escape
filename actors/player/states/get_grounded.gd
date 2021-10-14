extends 'res://actors/player/states/player_state.gd'

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    var ground_detector := player.get_ground_detector()
    ground_detector.force_raycast_update()
    player.global_position = ground_detector.get_collision_point()

func exit(player: Player) -> void:
    pass

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    return {'new_state': Player.State.NEXT_STATE_IN_SEQUENCE}
