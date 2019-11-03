extends 'res://actors/player/states/state.gd'

# The duration of the stagger state. Note that this does not necessarily align
# with the number of invincibility frames that the player will have after being
# hit, as that is controlled separately so that the player can still have
# invincibility for a bit while in other states.
const STAGGER_DURATION: float = 0.25

# The speed, in pixels per second, at which the player is knocked back.
const STAGGER_SPEED: float = 10.0 * Util.TILE_SIZE

var velocity: Vector2 = Vector2.ZERO

onready var _stagger_duration_timer: Timer = $StaggerDurationTimer

func _ready() -> void:
    # Set up stagger duration timer.
    _stagger_duration_timer.wait_time = STAGGER_DURATION
    _stagger_duration_timer.one_shot = true

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    # Set the initial velocity corresponding to the knockback force. For now we
    # assume the knockback direction is always up and away
    velocity = STAGGER_SPEED * Vector2(-player.get_direction(), -1).normalized()

    _stagger_duration_timer.start()

    player.get_animation_player().play('stagger')

func exit(player: Player) -> void:
    pass

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    var physics_manager := player.get_physics_manager()

    # Once the stagger finishes, we either fall if we're currently airborne or
    # idle otherwise.
    if _stagger_duration_timer.is_stopped():
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