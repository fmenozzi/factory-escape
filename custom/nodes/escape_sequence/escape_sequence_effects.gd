extends CanvasLayer

signal escape_sequence_started
signal escape_sequence_stopped

onready var _shake_timer: Timer = $ShakeTimer
onready var _debris_spawn_point: Position2D = $DebrisSpawnPoint
onready var _rumble_sounds: Array = [
	$RumbleSounds/Rumble1,
	$RumbleSounds/Rumble2,
	$RumbleSounds/Rumble3,
]

var _rng := RandomNumberGenerator.new()
var _active := false

func _ready() -> void:
	_shake_timer.one_shot = false
	_shake_timer.connect('timeout', self, '_on_shake_timeout')

func start() -> void:
	_shake_timer.start(0.1)
	_active = true

	emit_signal('escape_sequence_started')

func stop() -> void:
	_shake_timer.stop()
	_active = false

	emit_signal('escape_sequence_stopped')

func stop_debris() -> void:
	_shake_timer.stop()

func is_active() -> bool:
	return _active

func lamp_reset() -> void:
	stop()

func _get_global_debris_spawn_point() -> Vector2:
	return get_tree().get_root().canvas_transform.affine_inverse().xform(
		_debris_spawn_point.position)

func _on_shake_timeout() -> void:
	Screenshake.start(
		Screenshake.Duration.MEDIUM, Screenshake.Amplitude.SMALL,
		Screenshake.Priority.HIGH)
	Rumble.start(Rumble.Type.WEAK, 0.5, Rumble.Priority.HIGH)

	_rumble_sounds[_rng.randi_range(0, 2)].play()

	Effects.spawn_debris_at(_get_global_debris_spawn_point())

	_shake_timer.start(rand_range(1.0, 7.0))
