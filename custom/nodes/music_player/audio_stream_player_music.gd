extends AudioStreamPlayer
class_name AudioStreamPlayerMusic

export(float, -80.0, 24.0) var max_volume_db := 0.0

onready var tween: Tween = $FadeTween

# This variable serves solely as a property for the fade tween to interpolate.
# The real work of changing the volume will happen at each tween step.
var _fade_volume_linear

func _ready() -> void:
    volume_db = max_volume_db

    tween.connect('tween_step', self, '_on_tween_step')

func play(from_position: float = 0.0) -> void:
    volume_db = max_volume_db
    .play(from_position)

func stop() -> void:
    # Include the call to seek() to ensure that the music stops playing when
    # stop() is called. This ensure that music will not continue to play if
    # stop() is called too soon after play().
    seek(-1)
    .stop()

func is_playing() -> bool:
    return playing and volume_db > -80.0

func set_max_volume_db(new_max_volume_db: float) -> void:
    max_volume_db = new_max_volume_db
    volume_db = max_volume_db

func fade_in(duration: float, from_position: float = 0.0) -> void:
    _fade(0.0, 1.0, duration, from_position)

func fade_out(duration: float, from_position: float = 0.0) -> void:
    _fade(1.0, 0.0, duration, from_position)

func _fade(old_volume_linear: float, new_volume_linear: float, duration: float, from_position: float) -> void:
    _fade_volume_linear = old_volume_linear

    if not playing:
        play(from_position)

    tween.interpolate_property(
        self, '_fade_volume_linear', old_volume_linear, new_volume_linear, duration)
    tween.start()

func _on_tween_step(obj, key, elapsed, val: float) -> void:
    volume_db = Audio.linear_to_db(val, max_volume_db)
