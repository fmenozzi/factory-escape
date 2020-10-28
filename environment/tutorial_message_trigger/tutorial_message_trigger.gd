extends Area2D

signal player_entered_area(message_mode, message, player_action)
signal player_exited_area(message_mode, message, player_action)

export(TutorialMessage.MessageMode) var message_mode := TutorialMessage.MessageMode.NON_CONTROL

# Regardless of message mode, we need a string for the explanatory text.
export(String) var message := ''

# If the message mode is CONTROL, we need a string for the player_action (from
# which the keyboard button label and controller button texture will be derived).
export(String) var player_action := ''

func _ready() -> void:
    self.connect('body_entered', self, '_on_player_entered')
    self.connect('body_exited', self, '_on_player_exited')

    assert(not message.empty())

    if message_mode == TutorialMessage.MessageMode.CONTROL:
        assert(not player_action.empty())

func _on_player_entered(player: Player) -> void:
    if not player:
        return

    emit_signal('player_entered_area', message_mode, message, player_action)

func _on_player_exited(player: Player) -> void:
    if not player:
        return

    emit_signal('player_exited_area', message_mode, message, player_action)
