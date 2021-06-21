extends 'res://actors/enemies/enemy_state.gd'

const ALERTED_DURATION: float = 0.25

var _player: Player = null

onready var _timer: Timer = $AlertedDurationTimer

func _ready() -> void:
    _timer.one_shot = true
    _timer.wait_time = ALERTED_DURATION

func enter(sticky_drone: StickyDrone, previous_state_dict: Dictionary) -> void:
    _player = Util.get_player()

    # Pause current animation.
    sticky_drone.get_animation_player().stop(false)

    sticky_drone.get_sound_manager().play(StickyDroneSoundManager.Sounds.ALERTED)

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

    if not aggro_manager.in_aggro_range() or not aggro_manager.can_see_player():
        return {'new_state': StickyDrone.State.UNALERTED}

    return {'new_state': StickyDrone.State.NO_CHANGE}
