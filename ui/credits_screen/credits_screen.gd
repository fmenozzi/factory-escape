extends Control

onready var _timer: Timer = $Timer
onready var _tween: Tween = $FadeTween
onready var _pages: Control = $Pages

var _current_page_idx := 0
var _is_fading_in_or_out := false

func _ready() -> void:
    MouseCursor.set_mouse_mode(MouseCursor.MouseMode.HIDDEN)

    set_process_unhandled_input(false)
    if SceneChanger.is_changing_scene():
        yield(SceneChanger, 'scene_changed')

    _timer.one_shot = true
    _timer.wait_time = 4.0
    _timer.connect('timeout', self, '_on_timeout')
    _timer.start()

    set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed('ui_accept'):
        if _is_fading_in_or_out:
            return
        _go_to_next_screen()
    elif event.is_action_pressed('ui_cancel'):
        set_process_unhandled_input(false)
        _go_to_title_screen()

func _go_to_title_screen() -> void:
    var fade_in_delay := 2.0
    SceneChanger.change_scene_to(Preloads.TitleScreen, fade_in_delay)

func _go_to_next_screen() -> void:
    _timer.start()

    var current_page := _pages.get_child(_current_page_idx)
    _tween.remove_all()
    _tween.interpolate_property(current_page, 'modulate:a', 1.0, 0.0, 1.0)
    _tween.start()
    _is_fading_in_or_out = true
    yield(_tween, 'tween_all_completed')
    _is_fading_in_or_out = false

    _current_page_idx += 1
    current_page = _pages.get_child(_current_page_idx)

    _tween.remove_all()
    _tween.interpolate_property(current_page, 'modulate:a', 0.0, 1.0, 1.0)
    _tween.start()
    _is_fading_in_or_out = true
    yield(_tween, 'tween_all_completed')
    _is_fading_in_or_out = false

func _on_timeout() -> void:
    _timer.stop()
    if _current_page_idx >= _pages.get_child_count() - 1:
        var current_page := _pages.get_child(_current_page_idx)
        _tween.remove_all()
        _tween.interpolate_property(current_page, 'modulate:a', 1.0, 0.0, 1.0)
        _tween.start()

        _on_credits_ended()
    else:
        _go_to_next_screen()

func _on_credits_ended() -> void:
    # Once we reach the end of the credits, disable input handling to ensure
    # that we only change scenes once.
    set_process_unhandled_input(false)

    _go_to_title_screen()
