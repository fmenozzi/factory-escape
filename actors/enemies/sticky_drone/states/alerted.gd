extends 'res://actors/enemies/enemy_state.gd'

const ALERTED_DURATION: float = 1.0

var _player: Player = null

onready var _timer: Timer = $AlertedDurationTimer

func _ready() -> void:
    _timer.one_shot = true
    _timer.wait_time = ALERTED_DURATION

func enter(sticky_drone: StickyDrone, previous_state_dict: Dictionary) -> void:
    _player = Util.get_player()

    # Pause current animation.
    sticky_drone.get_animation_player().stop(false)

    # Display alerted reaction.
    sticky_drone.get_react_sprite().change_state(ReactSprite.State.ALERTED)

    # Turn to face player when alerted.
    sticky_drone.set_direction(Util.direction(sticky_drone, _player))

    # Start duration timer.
    _timer.start()

func exit(sticky_drone: StickyDrone) -> void:
    # Hide reaction sprite.
    sticky_drone.get_react_sprite().change_state(ReactSprite.State.NONE)

func update(sticky_drone: StickyDrone, delta: float) -> Dictionary:
    var aggro_manager := sticky_drone.get_aggro_manager()

    if _timer.is_stopped():
        return {'new_state': StickyDrone.State.CROUCH}

    # Once aggroed, sticky drone will only unaggro when out of range, and NOT
    # when player is no longer in line of sight (i.e. the drone will "track" the
    # player through cover).
    if not aggro_manager.in_aggro_range():
        return {'new_state': StickyDrone.State.UNALERTED}

    return {'new_state': StickyDrone.State.NO_CHANGE}
