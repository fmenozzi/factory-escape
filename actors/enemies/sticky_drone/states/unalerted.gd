extends 'res://actors/enemies/state.gd'

const UNALERTED_DURATION: float = 2.0

var _player: Player = null

onready var _unalerted_duration_timer: Timer = $UnalertedDurationTimer
onready var _turn_around_duration_timer: Timer = $TurnAroundDurationTimer

func _ready() -> void:
    _unalerted_duration_timer.one_shot = true
    _unalerted_duration_timer.wait_time = UNALERTED_DURATION

    _turn_around_duration_timer.one_shot = false
    _turn_around_duration_timer.wait_time = UNALERTED_DURATION / 2.0

func enter(sticky_drone: StickyDrone, previous_state_dict: Dictionary) -> void:
    # Pause current animation.
    sticky_drone.get_animation_player().stop(false)

    # Display unalerted reaction.
    sticky_drone.get_react_sprite().change_state(ReactSprite.State.UNALERTED)

    # Start timers.
    _turn_around_duration_timer.connect(
        'timeout', self, '_on_turn_around_timeout', [sticky_drone])
    _unalerted_duration_timer.start()
    _turn_around_duration_timer.start()

    _player = Util.get_player()

func exit(sticky_drone: StickyDrone) -> void:
    # Hide reaction sprite.
    sticky_drone.get_react_sprite().change_state(ReactSprite.State.NONE)

    # Stop timers.
    _unalerted_duration_timer.stop()
    _turn_around_duration_timer.stop()

func update(sticky_drone: StickyDrone, delta: float) -> Dictionary:
    var aggro_manager := sticky_drone.get_aggro_manager()

    # Transition back to alerted once back in aggro radius.
    if aggro_manager.in_aggro_range() and aggro_manager.can_see_player():
        return {'new_state': StickyDrone.State.ALERTED}

    # Transition back to idle once out of "unaggro" radius.
    if _unalerted_duration_timer.is_stopped():
        if not (aggro_manager.in_unaggro_range() and aggro_manager.can_see_player()):
            return {'new_state': StickyDrone.State.IDLE}

    return {'new_state': StickyDrone.State.NO_CHANGE}

func _on_turn_around_timeout(sticky_drone: StickyDrone) -> void:
    sticky_drone.set_direction(sticky_drone.direction * -1)
