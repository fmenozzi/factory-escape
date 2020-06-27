extends 'res://actors/player/states/player_state.gd'

# The duration of the stagger state. Note that this does not necessarily align
# with the number of invincibility frames that the player will have after being
# hit, as that is controlled separately so that the player can still have
# invincibility for a bit while in other states.
const STAGGER_DURATION: float = 0.25

# The speed, in pixels per second, at which the player is knocked back.
const STAGGER_SPEED: float = 10.0 * Util.TILE_SIZE

var velocity: Vector2 = Vector2.ZERO

onready var _knockback_duration_timer: Timer = $KnockbackDurationTimer

func _ready() -> void:
    # Set up knockback duration timer.
    _knockback_duration_timer.wait_time = STAGGER_DURATION
    _knockback_duration_timer.one_shot = true

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    # Set the initial velocity corresponding to the knockback force.
    assert('direction_from_hit' in previous_state_dict)
    var x_direction_from_hit: int = previous_state_dict['direction_from_hit']
    velocity = STAGGER_SPEED * Vector2(x_direction_from_hit, -1).normalized()

    _knockback_duration_timer.start()

    # Make the player collidable with enemy barriers for the duration of the
    # knockback so that the player is not knocked into the adjacent room.
    Collision.set_mask(player, 'enemy_barrier', true)

func exit(player: Player) -> void:
    Collision.set_mask(player, 'enemy_barrier', false)

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    var physics_manager := player.get_physics_manager()

    # Once the knockback finishes, we either fall if we're currently airborne or
    # idle otherwise.
    if _knockback_duration_timer.is_stopped():
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
