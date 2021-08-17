extends Area2D

signal player_entered_area(message_mode, message, player_action)
signal player_exited_area(message_mode, message, player_action)
signal control_remapped(player_action)

export(TutorialMessage.MessageMode) var message_mode := TutorialMessage.MessageMode.NON_CONTROL

# Regardless of message mode, we need a string for the explanatory text.
export(String) var message := ''

# If the message mode is CONTROL, we need a string for the player_action (from
# which the keyboard button label and controller button texture will be derived).
export(String) var player_action := ''

# The amount of time in seconds to wait after the player enters the trigger area
# before emitting the player_entered_area signal.
export(float) var delay := 0.0

# The trigger area only triggers the text if the node is active.
export(bool) var is_active := true

onready var _save_manager: TutorialMessageTriggerSaveManager = $SaveManager

func _ready() -> void:
    self.connect('body_entered', self, '_on_player_entered')
    self.connect('body_exited', self, '_on_player_exited')

    assert(not message.empty())

    if message_mode == TutorialMessage.MessageMode.CONTROL:
        assert(not player_action.empty())

        Controls.connect('control_remapped', self, '_on_control_remapped')

func set_is_active(active: bool) -> void:
    is_active = active

    # In case the player is inside the trigger area when we activate it.
    if is_active:
        for body in get_overlapping_bodies():
            if body is Player:
                _on_player_entered(body)

func _on_player_entered(player: Player) -> void:
    if not player or not is_active:
        return

    _save_manager.player_entered = true

    if delay > 0:
        yield(get_tree().create_timer(delay), 'timeout')

    emit_signal('player_entered_area', message_mode, message, player_action)

func _on_player_exited(player: Player) -> void:
    if not player or not is_active:
        return

    emit_signal('player_exited_area', message_mode, message, player_action)

    set_is_active(false)

    # As of 3.2 we need to use call_deferred here.
    self.call_deferred('disconnect', 'body_entered', self, '_on_player_entered')
    self.call_deferred('disconnect', 'body_exited', self, '_on_player_exited')

func _on_control_remapped(action: String, new_event: InputEvent) -> void:
    if action == player_action and is_active:
        emit_signal('control_remapped', player_action)
