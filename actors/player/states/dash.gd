extends 'res://actors/player/states/state.gd'

# The distance covered by the dash in pixels.
var DASH_DISTANCE: float = 4 * Util.TILE_SIZE

# The duration of the dash in seconds.
const DASH_DURATION: float = 0.20

# The speed at which the player moves when dashing, measured in pixels per
# second and calculated based on dash duration and dash distance.
var DASH_SPEED: float

# The delay between emissions of the dash echo.
var DASH_ECHO_DELAY: float = 0.05

var _previous_state_enum: int

const DashEcho = preload('res://actors/player/DashEcho.tscn')

onready var _dash_duration_timer: Timer = $DashDurationTimer
onready var _dash_echo_timer: Timer = $DashEchoTimer

func _ready() -> void:
    # Set up dash duration timer.
    _dash_duration_timer.wait_time = DASH_DURATION
    _dash_duration_timer.one_shot = true

    # Set up dash echo timer.
    _dash_echo_timer.wait_time = DASH_ECHO_DELAY

    # Calculate dash speed from the specified dash distance and duration.
    DASH_SPEED = DASH_DISTANCE / DASH_DURATION

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    var dash_manager := player.get_dash_manager()

    # Reset dash duration, dash cooldown, and dash echo timers.
    _dash_duration_timer.start()
    _dash_echo_timer.connect('timeout', self, '_on_dash_echo_timeout', [player])
    _dash_echo_timer.start()
    dash_manager.get_dash_cooldown_timer().stop()

    player.emit_dash_puff()

    # Reset player velocity.
    player.velocity = Vector2.ZERO

    # Play dash animation.
    player.get_animation_player().play('dash')

    dash_manager.consume_dash()

    _previous_state_enum = previous_state_dict['previous_state']

func exit(player: Player) -> void:
    # Start the cooldown timer once the dash finishes.
    player.get_dash_manager().get_dash_cooldown_timer().start()

    # Stop the dash echo timer.
    _dash_echo_timer.disconnect('timeout', self, '_on_dash_echo_timeout')
    _dash_echo_timer.stop()

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

func _on_dash_echo_timeout(player: Player) -> void:
    # TODO: Configure dash in terms of how many echoes to emit and consider not
    #       emitting an echo right under the player.

    var echo = DashEcho.instance()

    # Add echo node above player but below the rest of the world so that it's
    # drawn under the player but over the rest of the world.
    #
    # TODO: Consider creating a dedicated node in World for the dash echos in
    #       order to make this reasoning a little more clear (and also to avoid
    #       this fairly brittle solution that uses hard-coded indices).
    var player_parent := player.get_parent()
    player_parent.add_child(echo)
    player_parent.move_child(echo, 1)

    echo.flip_h = (player.get_direction() == -1)
    # TODO: Why is there this 8 pixel offset?
    echo.set_global_position(player.get_global_position() + Vector2(0, -8))
