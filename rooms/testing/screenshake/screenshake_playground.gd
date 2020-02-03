extends Room

onready var _player: Player = $Player
onready var _camera: Camera2D = _player.get_camera()
onready var _screenshake: Node2D = _camera.get_node('Screenshake')

onready var _duration_options: OptionButton = $OptionButtons/DurationOptions
onready var _frequency_options: OptionButton = $OptionButtons/FrequencyOptions
onready var _amplitude_options: OptionButton = $OptionButtons/AmplitudeOptions

var _is_shaking := false

func _ready() -> void:
    _duration_options.add_item('duration short', 0)
    _duration_options.add_item('duration medium', 1)
    _duration_options.add_item('duration long', 2)

    _frequency_options.add_item('frequency standard', 0)

    _amplitude_options.add_item('amplitude small', 0)
    _amplitude_options.add_item('amplitude medium', 1)
    _amplitude_options.add_item('amplitude large', 2)

    _screenshake.connect('started_shaking', self, '_on_started_shaking')
    _screenshake.connect('stopped_shaking', self, '_on_stopped_shaking')

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed('player_interact'):
        if _is_shaking:
            _stop_shaking()
        else:
            _start_shaking()

func _start_shaking() -> void:
    var duration := 0.0
    match _duration_options.selected:
        0:
            duration = _screenshake.SHAKE_DURATION_SHORT
        1:
            duration = _screenshake.SHAKE_DURATION_MEDIUM
        2:
            duration = _screenshake.SHAKE_DURATION_LONG

    var amplitude := 0.0
    match _amplitude_options.selected:
        0:
            amplitude = _screenshake.SHAKE_AMPL_SMALL
        1:
            amplitude = _screenshake.SHAKE_AMPL_MEDIUM
        2:
            amplitude = _screenshake.SHAKE_AMPL_LARGE

    _camera.shake(duration, _screenshake.SHAKE_FREQ, amplitude)

func _stop_shaking() -> void:
    _screenshake.stop()

func _on_started_shaking() -> void:
    _is_shaking = true
func _on_stopped_shaking() -> void:
    _is_shaking = false
