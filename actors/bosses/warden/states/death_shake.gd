extends 'res://actors/enemies/enemy_state.gd'

export(float, EASE) var damp_easing := 1.0

onready var _timer: Timer = $ShakeDuration

func _ready() -> void:
    _timer.one_shot = true
    _timer.wait_time = 1.0

func enter(warden: Warden, previous_state_dict: Dictionary) -> void:
    warden.set_direction(Util.direction(warden, Util.get_player()))
    warden.get_sprite().visible = false
    warden.get_shakeable_sprites().visible = true

    Screenshake.start(
        Screenshake.Duration.MEDIUM, Screenshake.Amplitude.SMALL,
        Screenshake.Priority.HIGH)
    Rumble.start(Rumble.Type.WEAK, 0.75, Rumble.Priority.HIGH)

    _timer.start()

func exit(warden: Warden) -> void:
    warden.get_sprite().visible = true
    warden.get_shakeable_sprites().visible = false
    warden.reset_shakeable_sprite_position()

func update(warden: Warden, delta: float) -> Dictionary:
    var damping := ease(_timer.time_left / _timer.wait_time, damp_easing)
    warden.shake_once(damping)

    if _timer.is_stopped():
        return {'new_state': Warden.State.NEXT_STATE_IN_SEQUENCE}

    return {'new_state': Warden.State.NO_CHANGE}
