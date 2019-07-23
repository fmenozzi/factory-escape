extends "res://scripts/state.gd"

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    player.get_animation_player().play('grapple_launch')

    # Make the player face the grapple point.
    var grapple_point := player.get_closest_grapple_point()
    var grapple_direction := sign((grapple_point - player.global_position).x)
    player.set_player_direction(grapple_direction)

    # Draw grapple rope from player to grapple point.
    var grapple_rope := player.get_grapple_rope()
    grapple_rope.add_point(Vector2.ZERO)
    grapple_rope.add_point(grapple_point - player.position)

func exit(player: Player) -> void:
    player.get_grapple_rope().clear_points()

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    return {'new_state': player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    # Once we finish the grapple animation, switch to the actual grapple state.
    if not player.get_animation_player().is_playing():
        return {'new_state': player.State.GRAPPLE}

    return {'new_state': player.State.NO_CHANGE}