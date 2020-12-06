extends Control

# The time to wait in seconds before incrementing the vertical scroll value.
const SCROLL_TIMER_WAIT_TIME := 0.05

onready var _timer: Timer = $ScrollSpeedTimer
onready var _scroll_container: ScrollContainer = $ScrollContainer
onready var _vbox_container: VBoxContainer = $ScrollContainer/VBoxContainer

var _max_scroll_value := -1

func _ready() -> void:
    set_process_unhandled_input(false)

    SceneChanger.connect('scene_changed', self, '_on_scene_changed')

    # Read credits data from file and add a Label to the ScrollContainer's
    # VBoxContainer for each line in the file.
    for label in _get_line_labels():
        _vbox_container.add_child(label)

    _max_scroll_value = _scroll_container.get_v_scrollbar().max_value

    _timer.one_shot = false
    _timer.wait_time = SCROLL_TIMER_WAIT_TIME
    _timer.connect('timeout', self, '_on_scroll_timeout')
    _timer.start()

func _unhandled_input(event: InputEvent) -> void:
    # Once the scene trasition completes, any key/button press advances back to
    # the main menu.
    if event is InputEventKey or event is InputEventJoypadButton:
        set_process_unhandled_input(false)

        _go_to_title_screen()

func _go_to_title_screen() -> void:
    var fade_in_delay := 2.0
    SceneChanger.change_scene_to(Preloads.TitleScreen, fade_in_delay)

func _get_line_labels() -> Array:
    var file := File.new()
    assert(file.open('res://ui/credits_screen/data/credits.tres', File.READ) == OK)

    var line_labels := []

    while not file.eof_reached():
        var label := Label.new()
        label.align = Label.ALIGN_CENTER
        label.text = file.get_line()

        line_labels.append(label)

    file.close()

    return line_labels

func _on_scene_changed() -> void:
    set_process_unhandled_input(true)

func _on_scroll_timeout() -> void:
    _scroll_container.scroll_vertical += 1

    if _scroll_container.scroll_vertical >= _max_scroll_value:
        # Once we reach the end of the credits, disable input handling and
        # disconnect timer callback to ensure that we only change scenes once.
        _timer.call_deferred('disconnect', 'timeout', self, '_on_scroll_timeout')
        set_process_unhandled_input(false)

        _go_to_title_screen()
