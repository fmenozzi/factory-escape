extends Room

onready var _type_option: OptionButton = $RumbleControls/Container/Settings/Type
onready var _duration: SpinBox = $RumbleControls/Container/Settings/Duration
onready var _test_rumble: Button = $RumbleControls/Container/TestRumble

onready var _is_rumbling := false

func _ready() -> void:
    _type_option.add_item('weak', 0)
    _type_option.add_item('strong', 1)

    _test_rumble.connect('button_down', self, '_on_test_rumble_pressed')

    Rumble.connect('rumble_started', self, '_on_rumble_started')
    Rumble.connect('rumble_stopped', self, '_on_rumble_stopped')

func _on_test_rumble_pressed() -> void:
    if _is_rumbling:
        Rumble.stop()
        _is_rumbling = false
        return

    match _type_option.selected:
        0:
            Rumble.start(Rumble.Type.WEAK, _duration.value)
        1:
            Rumble.start(Rumble.Type.STRONG, _duration.value)

func _on_rumble_started() -> void:
    _is_rumbling = true
    _test_rumble.text = 'Stop'
    print('rumble started')

func _on_rumble_stopped() -> void:
    _is_rumbling = false
    _test_rumble.text = 'Test Rumble'
    print('rumble stopped')
