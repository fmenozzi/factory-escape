extends Control

onready var _black_overlay: TextureRect = $BlackOverlay
onready var _rich_text_label: RichTextLabel = $RichTextLabel
onready var _player: Player = get_parent().get_parent().get_node('World').get_node('Player')

enum State {
    ENABLED,
    DISABLED,
}
var _current_state: int = State.DISABLED

func _unhandled_input(event: InputEvent) -> void:
    match _current_state:
        State.ENABLED:
            if event.is_action_pressed('ui_cancel'):
                _black_overlay.visible = false
                _rich_text_label.visible = false

                _player.set_process_unhandled_input(true)
                _player.set_physics_process(true)

                _current_state = State.DISABLED

        State.DISABLED:
            if event.is_action_pressed('player_interact'):
                _black_overlay.visible = true
                _rich_text_label.visible = true

                _player.set_process_unhandled_input(false)
                _player.set_physics_process(false)

                _current_state = State.ENABLED