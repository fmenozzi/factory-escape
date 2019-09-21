extends "res://scripts/state.gd"

const LandingPuff := preload('res://sfx/LandingPuff.tscn')

var TERMINAL_VELOCITY: float = 20 * Util.TILE_SIZE

var velocity: Vector2 = Vector2.ZERO

var grapple_point: GrapplePoint = null

func grapple_velocity(player: Player, grapple_point: GrapplePoint) -> Vector2:
    var dest := grapple_point.global_position
    if grapple_point.get_grapple_type() == GrapplePoint.GrappleType.LAUNCH:
        # Use the player direction to grapple point to decide whether to use the
        # left or right launch point as the grapple destination.
        var launch_points := grapple_point.get_launch_grapple_points()
        match Util.direction(player, grapple_point):
            -1:
                # Left; use left grapple launch point.
                dest = launch_points[0].global_position
            1:
                # Right; use right grapple launch point.
                dest = launch_points[1].global_position

    var disp := dest - player.global_position

    # The height from the higher of the two points to the highest point in the
    # arc.
    var h := Util.TILE_SIZE

    # The total height from the lower of the two points to the highest point in
    # the arc.
    var H := abs(disp.y) + h

    var g := player.GRAVITY

    var player_below_dest := disp.y < 0

    var time_up := sqrt(2 * (H if player_below_dest else h) / g)
    var time_down := sqrt(2 * (h if player_below_dest else H) / g)

    var velocity := Vector2.ZERO
    velocity.x = disp.x / float(time_up + time_down)
    velocity.y = -sqrt(2 * (H if player_below_dest else h) * g)
    return velocity

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    grapple_point = previous_state_dict['grapple_point']
    assert grapple_point != null

    velocity = grapple_velocity(player, grapple_point)

    player.get_animation_player().play('grapple_pull')
    player.get_animation_player().queue('jump')

func exit(player: Player) -> void:
    grapple_point.set_available(true)
    grapple_point = null

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    if event.is_action_pressed('player_grapple'):
        var next_grapple_point := player.get_next_grapple_point()
        if next_grapple_point != null and next_grapple_point != grapple_point:
            return {
                'new_state': player.State.GRAPPLE_START,
                'grapple_point': next_grapple_point,
            }

    return {'new_state': player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    velocity.y = min(velocity.y + player.GRAVITY * delta, TERMINAL_VELOCITY)
    player.move(velocity)

    if player.is_on_ground():
        Util.spawn_particles(LandingPuff.instance(), player)
        return {'new_state': player.State.IDLE}

    if player.is_on_wall():
        Util.spawn_particles(LandingPuff.instance(), player)
        return {'new_state': player.State.WALL_SLIDE}

    if velocity.y > 0:
        player.get_animation_player().play('fall')

    return {'new_state': player.State.NO_CHANGE}
