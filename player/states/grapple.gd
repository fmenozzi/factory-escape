extends "res://scripts/state.gd"

const LandingPuff := preload('res://sfx/LandingPuff.tscn')

var TERMINAL_VELOCITY: float = 20 * Globals.TILE_SIZE

var velocity: Vector2 = Vector2.ZERO

func grapple_velocity(player: Player, grapple_point: Vector2) -> Vector2:
    var disp := grapple_point - player.global_position

    # The height from the higher of the two points to the highest point in the
    # arc.
    var h := Globals.TILE_SIZE

    # The total height from the lower of the two points to the highest point in
    # the arc.
    var H := abs(disp.y) + h

    var g := player.GRAVITY

    var player_below_grapple_point := disp.y < 0

    var time_up := sqrt(2 * (H if player_below_grapple_point else h) / g)
    var time_down := sqrt(2 * (h if player_below_grapple_point else H) / g)

    var velocity :=  Vector2.ZERO
    velocity.x = disp.x / float(time_up + time_down)
    velocity.y = -sqrt(2 * (H if player_below_grapple_point else h) * g)
    return velocity

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    velocity = grapple_velocity(player, player.get_closest_grapple_point())

    player.get_animation_player().play('grapple_pull')
    player.get_animation_player().queue('jump')

func exit(player: Player) -> void:
    pass

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    return {'new_state': player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    velocity.y = min(velocity.y + player.GRAVITY * delta, TERMINAL_VELOCITY)
    player.move(velocity)

    if player.is_on_ground():
        Globals.spawn_particles(LandingPuff.instance(), player)
        return {'new_state': player.State.IDLE}

    if velocity.y > 0:
        player.get_animation_player().play('fall')

    return {'new_state': player.State.NO_CHANGE}
