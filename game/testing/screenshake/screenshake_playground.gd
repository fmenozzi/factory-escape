extends RoomFe

onready var _duration_options: OptionButton = $OptionButtons/DurationOptions
onready var _amplitude_options: OptionButton = $OptionButtons/AmplitudeOptions

var _is_shaking := false

func _ready() -> void:
    _duration_options.add_item('duration short', 0)
    _duration_options.add_item('duration medium', 1)
    _duration_options.add_item('duration long', 2)

    _amplitude_options.add_item('amplitude small', 0)
    _amplitude_options.add_item('amplitude medium', 1)
    _amplitude_options.add_item('amplitude large', 2)

    Screenshake.connect('started_shaking', self, '_on_started_shaking')
    Screenshake.connect('stopped_shaking', self, '_on_stopped_shaking')

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed('player_interact'):
        if _is_shaking:
            _stop_shaking()
        else:
            _start_shaking()

func _start_shaking() -> void:
    var duration := -1
    match _duration_options.selected:
        0:
            duration = Screenshake.Duration.SHORT
        1:
            duration = Screenshake.Duration.MEDIUM
        2:
            duration = Screenshake.Duration.LONG

    var amplitude := -1
    match _amplitude_options.selected:
        0:
            amplitude = Screenshake.Amplitude.SMALL
        1:
            amplitude = Screenshake.Amplitude.MEDIUM
        2:
            amplitude = Screenshake.Amplitude.LARGE

    Screenshake.start(duration, amplitude)

func _stop_shaking() -> void:
    Screenshake.stop()

func _on_started_shaking() -> void:
    _is_shaking = true
func _on_stopped_shaking() -> void:
    _is_shaking = false
