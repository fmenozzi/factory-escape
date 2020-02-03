extends Room

onready var _player: Player = $Player

onready var _duration_options: OptionButton = $OptionButtons/DurationOptions
onready var _frequency_options: OptionButton = $OptionButtons/FrequencyOptions
onready var _amplitude_options: OptionButton = $OptionButtons/AmplitudeOptions

func _ready() -> void:
    _duration_options.add_item('duration short', 0)
    _duration_options.add_item('duration medium', 1)
    _duration_options.add_item('duration long', 2)

    _frequency_options.add_item('frequency standard', 0)

    _amplitude_options.add_item('amplitude small', 0)
    _amplitude_options.add_item('amplitude medium', 1)
    _amplitude_options.add_item('amplitude large', 2)

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed('ui_up'):
        _start_shaking()
    if event.is_action_pressed('ui_down'):
        _stop_shaking()

func _start_shaking() -> void:
    var camera := _player.get_camera()
    var screenshake := camera.get_node('Screenshake')

    var duration := 0.0
    match _duration_options.selected:
        0:
            duration = screenshake.SHAKE_DURATION_SHORT
        1:
            duration = screenshake.SHAKE_DURATION_MEDIUM
        2:
            duration = screenshake.SHAKE_DURATION_LONG

    var amplitude := 0.0
    match _amplitude_options.selected:
        0:
            amplitude = screenshake.SHAKE_AMPL_SMALL
        1:
            amplitude = screenshake.SHAKE_AMPL_MEDIUM
        2:
            amplitude = screenshake.SHAKE_AMPL_LARGE

    camera.shake(duration, screenshake.SHAKE_FREQ, amplitude)

func _stop_shaking() -> void:
    var camera := _player.get_camera()
    var screenshake := camera.get_node('Screenshake')
    screenshake.stop()
