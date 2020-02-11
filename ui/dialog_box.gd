extends Control

# The amount of time in seconds that passes before the next letter shows up in
# the dialog box.
const SCROLL_SPEED: float = 0.05

onready var _black_overlay: TextureRect = $BlackOverlay
onready var _label: RichTextLabel = $RichTextLabel
onready var _timer: Timer = $TextScrollTimer

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
                        var nearby_sign := _player.get_nearby_sign()
                        nearby_sign.label_fade_in()
                        _stop_dialog()
                        _current_state = State.DISABLED

            # ui_cancel to exit the dialog box
            if event.is_action_pressed('ui_cancel'):
                var nearby_sign := _player.get_nearby_sign()
                nearby_sign.label_fade_in()
                _stop_dialog()
                _current_state = State.DISABLED

        State.DISABLED:
            # Ensure player is idle near a sign.
            var nearby_sign := _player.get_nearby_sign()
            if not nearby_sign or _player.current_state() != Player.State.IDLE:
                return

            _dialog = nearby_sign.dialog

            # player_interact to open up the dialog box when near a sign.
            if event.is_action_pressed('player_interact'):
                # Walk to closest reading point for sign.
                set_process_unhandled_input(false)
                _player.change_state({
                    'new_state': Player.State.WALK_TO_POINT,
                    'stopping_point': nearby_sign.get_closest_reading_point(),
                })
                yield(_player, 'player_walked_to_point')
                yield(get_tree(), 'physics_frame')
                set_process_unhandled_input(true)

                # Ensure player is facing sign.
                _player.set_direction(Util.direction(_player, nearby_sign))

                nearby_sign.label_fade_out()
                _start_dialog()
                _current_state = State.ENABLED

func _on_timeout() -> void:
    _label.set_visible_characters(_label.get_visible_characters() + 1)

func _start_dialog() -> void:
    _page = 0
    _label.set_bbcode(_dialog[_page])
    _label.set_visible_characters(0)

    _set_dialog_box_visible(true)
    _set_player_controllable(false)

    _timer.start()

func _stop_dialog() -> void:
    _set_dialog_box_visible(false)
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

func _set_dialog_box_visible(visible: bool) -> void:
    _black_overlay.visible = visible
    _label.visible = visible

func _set_player_controllable(controllable: bool) -> void:
    _player.set_process_unhandled_input(controllable)
    _player.set_physics_process(controllable)
