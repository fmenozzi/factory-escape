extends Control

onready var _error_code_label: Label = $VBoxContainer/ErrorCode
onready var _error_message_label: Label = $VBoxContainer/ErrorMessage

func _ready() -> void:
    _error_code_label.text = _convert_error_code_to_string(Error.error_code)
    _error_message_label.text = Error.error_message

    set_process_unhandled_input(false)
    yield(SceneChanger, 'scene_changed')
    set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
    # Once the scene trasition completes, any key/button press advances back to
    # the main menu.
    if event is InputEventKey or event is InputEventJoypadButton:
        set_process_unhandled_input(false)

        var fade_in_delay := 2.0
        SceneChanger.change_scene_to(Preloads.TitleScreen, fade_in_delay)

func _convert_error_code_to_string(error_code: int) -> String:
    # Consider whether matching on the actual ERR_ constants would be better
    # here.
    return 'Error code: %d' % error_code
