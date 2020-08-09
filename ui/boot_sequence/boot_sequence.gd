extends Control

onready var _sequence: Control = $Sequence
onready var _saving_indicator: Control = $Sequence/AutosaveFeature/SavingIndicator
onready var _screen_fadeout: Control = $ScreenFadeout
onready var _timer: Timer = $Timer

var _idx := 0

func _ready() -> void:
    # Start boot sequence in window mode specified in options. If window mode is
    # not specified in options (e.g. the options file has not been created yet),
    # then default to fullscreen.
    Options.load_options()
    match Options.get_config().get_value('video', 'window_mode', 'Fullscreen'):
        'Fullscreen':
            OS.window_fullscreen = true

        'Windowed':
            OS.window_fullscreen = false

    # Start spinning the saving indicator.
    _saving_indicator.start_spinning_for(0.0)

    _timer.one_shot = true
    _timer.wait_time = 2.0
    _timer.connect('timeout', self, '_on_timeout')
    _timer.start()

func _go_to_next_screen_in_sequence() -> void:
    var fade_duration := 1.0

    _screen_fadeout.fade_to_black(fade_duration)
    yield(_screen_fadeout, 'fade_to_black_finished')

    _sequence.get_child(_idx).visible = false
    _sequence.get_child(_idx + 1).visible = true
    _idx += 1

    _screen_fadeout.fade_from_black(fade_duration)
    yield(_screen_fadeout, 'fade_from_black_finished')

    _timer.start()

func _go_to_title_screen() -> void:
    var fade_duration := 1.0

    SceneChanger.change_scene_to(Preloads.TitleScreen, fade_duration)

func _on_timeout() -> void:
    if _idx < _sequence.get_child_count() - 1:
        _go_to_next_screen_in_sequence()
    else:
        _go_to_title_screen()
