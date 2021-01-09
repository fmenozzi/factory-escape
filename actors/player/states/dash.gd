extends 'res://actors/player/states/player_state.gd'

# The distance covered by the dash in pixels.
var DASH_DISTANCE: float = 4 * Util.TILE_SIZE

# The duration of the dash in seconds.
const DASH_DURATION: float = 0.20

# The speed at which the player moves when dashing, measured in pixels per
# second and calculated based on dash duration and dash distance.
var DASH_SPEED: float

var _previous_state_enum: int

onready var _dash_duration_timer: Timer = $DashDurationTimer

func _ready() -> void:
    # Set up dash duration timer.
    _dash_duration_timer.wait_time = DASH_DURATION
    _dash_duration_timer.one_shot = true

    # Calculate dash speed from the specified dash distance and duration.
    DASH_SPEED = DASH_DISTANCE / DASH_DURATION

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    var dash_manager := player.get_dash_manager()

    # Reset dash duration and dash cooldown timers.
    _dash_duration_timer.start()
    dash_manager.get_dash_cooldown_timer().stop()

    # Initiate various particle effects for dash.
    player.emit_dash_effects()

    # Reset player velocity.
    player.velocity = Vector2.ZERO

    # Play dash animation.
    player.get_animation_player().play('dash')

    player.get_sound_manager().play(PlayerSoundManager.Sounds.DASH)

    dash_manager.consume_dash()

    _previous_state_enum = previous_state_dict['previous_state']

func exit(player: Player) -> void:
    # Start the cooldown timer once the dash finishes.
    player.get_dash_manager().get_dash_cooldown_timer().start()

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    # Once the dash is complete, we either fall if we're currently airborne or
    # idle otherwise.
    if _dash_duration_timer.is_stopped():
        if player.is_in_air():
            # We want to treat dashing off a ledge as similar to walking off a
            # ledge (i.e. if we dash off a ledge we can only jump again if we
            # have the double jump). Importantly, this should not happen if we
            # dash in midair.
            if _previous_state_enum in [Player.State.IDLE, Player.State.WALK]:
                player.get_jump_manager().consume_jump()

            return {'new_state': Player.State.FALL}
        else:
            return {'new_state': Player.State.IDLE}

    # Dash in the direction the player is currently facing.
    player.velocity.x = player.get_direction() * DASH_SPEED
    player.move(player.velocity)

    return {'new_state': Player.State.NO_CHANGE}
