extends Control

# The amount of time in seconds that passes before the next letter shows up in
# the dialog box.
const SCROLL_SPEED: float = 0.05

onready var _black_overlay: ColorRect = $BlackOverlay
onready var _label: RichTextLabel = $RichTextLabel
onready var _timer: Timer = $TextScrollTimer
onready var _end_of_page_prompt: Control = $EndOfPagePrompt
onready var _end_of_page_prompt_animation_player: AnimationPlayer = $EndOfPagePrompt/AnimationPlayer

onready var _player: Player = Util.get_player()

enum State {
    ENABLED,
    DISABLED,
}
var _current_state: int = State.DISABLED

var _dialog: Array

var _page = 0

func _ready() -> void:
    _timer.set_wait_time(SCROLL_SPEED)
    _timer.connect('timeout', self, '_on_timeout')

func _unhandled_input(event: InputEvent) -> void:
    match _current_state:
        State.ENABLED:
            # ui_accept to skip to the end of a page and also to advance to the
            # next page.
            if event.is_action_pressed('ui_accept'):
                if _label.get_visible_characters() < _label.get_total_character_count():
                    _advance_dialog_to_end_of_current_page()
                else:
                    if _page < _dialog.size() - 1:
                        _advance_dialog_to_next_page()
                    else:
                        # End dialog if there is no more left to display.
                        _exit_dialog_box()

            # ui_cancel to exit the dialog box
            if event.is_action_pressed('ui_cancel'):
                _exit_dialog_box()

        State.DISABLED:
            # Ensure player is idle or walking near a sign.
            var nearby_readable_object := _player.get_nearby_readable_object()
            if not nearby_readable_object:
                return
            if not _player.current_state() in [Player.State.IDLE, Player.State.WALK]:
                return

            _dialog = nearby_readable_object.dialog

            # player_interact to open up the dialog box when near a sign.
            if event.is_action_pressed('player_interact'):
                set_process_unhandled_input(false)

                # Start READ_SIGN sequence.
                _player.change_state({
                    'new_state': Player.State.READ_SIGN,
                    'stopping_point': nearby_readable_object.get_closest_reading_point(),
                    'object_to_face': nearby_readable_object,
                })
                yield(_player.current_state, 'sequence_finished')

                nearby_readable_object.label_fade_out()
                _start_dialog()
                _current_state = State.ENABLED

                set_process_unhandled_input(true)

func _on_timeout() -> void:
    _label.set_visible_characters(_label.get_visible_characters() + 1)

    if _label.get_visible_characters() < _label.get_total_character_count():
        _set_end_of_page_prompt_visible(false)
    else:
        _set_end_of_page_prompt_visible(true)

func _start_dialog() -> void:
    _page = 0
    _label.set_bbcode(_dialog[_page])
    _label.set_visible_characters(0)

    _set_dialog_box_visible(true)
    _set_player_controllable(false)

    _timer.start()

func _exit_dialog_box(fade_in_label: bool = true) -> void:
    if fade_in_label:
        var nearby_readable_object := _player.get_nearby_readable_object()
        nearby_readable_object.label_fade_in()
    _stop_dialog()
    _current_state = State.DISABLED

func _stop_dialog() -> void:
    _set_dialog_box_visible(false)
    _set_end_of_page_prompt_visible(false)
    _set_player_controllable(true)

    _timer.stop()

func _advance_dialog_to_next_page() -> void:
    _page += 1
    _label.set_bbcode(_dialog[_page])
    _label.set_visible_characters(0)
    _timer.start()

func _advance_dialog_to_end_of_current_page() -> void:
    _timer.stop()
    _label.set_visible_characters(_label.get_total_character_count())
    _set_end_of_page_prompt_visible(true)

func _set_dialog_box_visible(visible: bool) -> void:
    _black_overlay.visible = visible
    _label.visible = visible

func _set_player_controllable(controllable: bool) -> void:
    _player.set_process_unhandled_input(controllable)

func _set_end_of_page_prompt_visible(visible: bool) -> void:
    _end_of_page_prompt.visible = visible

    if visible:
        _end_of_page_prompt_animation_player.play('flash')
    else:
        _end_of_page_prompt_animation_player.stop()

func _on_player_hit(player_health: int) -> void:
    if _current_state == State.ENABLED:
        var fade_in_label_on_exit = (player_health != 0)
        _exit_dialog_box(fade_in_label_on_exit)
