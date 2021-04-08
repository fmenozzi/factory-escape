extends 'res://actors/enemies/enemy_state.gd'

# The duration of rotating a full 180 degrees (PI radians). If the turret head
# is already partway through a full rotation, the rotation tween's duration will
# be altered accordingly.
const FULL_ROTATION_DURATION: float = 3.0

var _rotation_direction := 0.0
var _elapsed_rotation := 0.0

onready var _rotation_tween: Tween = $RotationTween

func enter(turret: Turret, previous_state_dict: Dictionary) -> void:
    assert('rotation_direction' in previous_state_dict)
    _rotation_direction = sign(previous_state_dict['rotation_direction'])

    var end_rotation := -PI/2 if _rotation_direction < 0 else PI/2
    _elapsed_rotation = turret.get_head_rotation()

    # Determine the fraction of the 180-degree arc that the turret head has to
    # travel, and adjust the tween duration such that the angular speed is
    # constant.
    var duration := 0.0
    if _rotation_direction < 0:
        duration = (PI/2 + _elapsed_rotation) / PI * FULL_ROTATION_DURATION
    else:
        duration = (PI/2 - _elapsed_rotation) / PI * FULL_ROTATION_DURATION

    _rotation_tween.remove_all()
    _rotation_tween.connect('tween_step', self, '_on_tween_step', [turret])
    _rotation_tween.interpolate_property(
        self, '_elapsed_rotation', _elapsed_rotation, end_rotation, duration,
        Tween.TRANS_LINEAR, Tween.EASE_IN)
    _rotation_tween.start()

    # Show scan line.
    turret.get_scanner().visible = true

    turret.get_sound_manager().play(EnemySoundManager.Sounds.TURRET_SCANNING)

func exit(turret: Turret) -> void:
    _rotation_tween.remove_all()

    turret.get_sound_manager().get_player(EnemySoundManager.Sounds.TURRET_SCANNING).stop()

func update(turret: Turret, delta: float) -> Dictionary:
    var scanner := turret.get_scanner()
    var aggro_manager := turret.get_aggro_manager()

    if scanner.is_colliding_with_player():
        return {
            'new_state': Turret.State.ALERTED,
            'already_aggroed': false
        }

    if not _rotation_tween.is_active():
        return {'new_state': Turret.State.WAIT}

    return {'new_state': Turret.State.NO_CHANGE}

func _on_tween_step(_obj, _key, _elapsed, val: float, turret: Turret) -> void:
    turret.rotate_head_to(val)
