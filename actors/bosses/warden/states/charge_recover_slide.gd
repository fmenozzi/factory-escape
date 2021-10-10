extends 'res://actors/enemies/enemy_state.gd'

export(Curve) var slide_easing: Curve

const MAX_SLIDE_SPEED := 6.0 * Util.TILE_SIZE

onready var _timer: Timer = $SlideDuration

func _ready() -> void:
    _timer.one_shot = true
    _timer.wait_time = 0.75

func enter(warden: Warden, previous_state_dict: Dictionary) -> void:
    warden.get_animation_player().play('charge_recover_slide')
    warden.emit_dust_puff_slide()

    _timer.start()

func exit(warden: Warden) -> void:
    pass

func update(warden: Warden, delta: float) -> Dictionary:
    if not warden.get_animation_player().is_playing():
        return {'new_state': Warden.State.DISPATCH}

    if warden.is_on_wall():
        return {'new_state': Warden.State.CHARGE_IMPACT}

    var w := (_timer.wait_time - _timer.time_left) / _timer.wait_time
    var speed_multiplier := slide_easing.interpolate(w)
    warden.move(Vector2(warden.direction * MAX_SLIDE_SPEED * speed_multiplier, 0))

    return {'new_state': Warden.State.NO_CHANGE}
