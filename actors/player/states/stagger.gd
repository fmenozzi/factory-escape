extends 'res://actors/player/states/state.gd'

# The duration of the stagger state. Note that this does not necessarily align
# with the number of invincibility frames that the player will have after being
# hit, as that is controlled separately so that the player can still have
# invincibility for a bit while in other states.
const STAGGER_DURATION: float = 0.25

# The speed, in pixels per second, at which the player is knocked back.
const STAGGER_SPEED: float = 10.0 * Util.TILE_SIZE

var velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
    # Set up stagger duration timer.
    $StaggerDuration.wait_time = STAGGER_DURATION
    $StaggerDuration.one_shot = true

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    # Set the initial velocity corresponding to the knockback force. For now we
    # assume the knockback direction is always up and away
    velocity = STAGGER_SPEED * Vector2(-player.get_direction(), -1).normalized()

    $StaggerDuration.start()

    player.get_animation_player().play('stagger')

func exit(player: Player) -> void:
    pass

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    var physics_manager := player.get_physics_manager()

    # Once the stagger finishes, we either fall if we're currently airborne or
    # idle otherwise.
    if $StaggerDuration.is_stopped():
        if player.is_in_air():
            return {'new_state': Player.State.FALL}
        else:
            return {'new_state': Player.State.IDLE}

    # Apply gravity with terminal velocity. Don't snap while staggering.
    velocity.y = min(
        velocity.y + physics_manager.get_gravity() * delta,
        physics_manager.get_terminal_velocity())
    player.move(velocity, Util.NO_SNAP)

    return {'new_state': Player.State.NO_CHANGE}