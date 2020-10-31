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

var _is_active := false
var _player_entered := false

onready var _save_key: String = get_path()

func _ready() -> void:
    self.connect('body_entered', self, '_on_player_entered')
    self.connect('body_exited', self, '_on_player_exited')

    assert(not message.empty())

    if message_mode == TutorialMessage.MessageMode.CONTROL:
        assert(not player_action.empty())

        Controls.connect('control_remapped', self, '_on_control_remapped')

func get_save_data() -> Array:
    return [_save_key, {
        'player_entered': _player_entered,
    }]

func load_save_data(all_save_data: Dictionary) -> void:
    if not _save_key in all_save_data:
        return

    var trigger_save_data: Dictionary = all_save_data[_save_key]
    assert('player_entered' in trigger_save_data)

    _player_entered = trigger_save_data['player_entered']

    if _player_entered:
        self.disconnect('body_entered', self, '_on_player_entered')
        self.disconnect('body_exited', self, '_on_player_exited')

func _on_player_entered(player: Player) -> void:
    if not player:
        return

    _is_active = true
    _player_entered = true

    if delay > 0:
        yield(get_tree().create_timer(delay), 'timeout')

    if _is_active:
        emit_signal('player_entered_area', message_mode, message, player_action)

func _on_player_exited(player: Player) -> void:
    if not player:
        return

    _is_active = false

    emit_signal('player_exited_area', message_mode, message, player_action)

    # As of 3.2 we need to use call_deferred here.
    self.call_deferred('disconnect', 'body_entered', self, '_on_player_entered')
    self.call_deferred('disconnect', 'body_exited', self, '_on_player_exited')

func _on_control_remapped(action: String, new_event: InputEvent) -> void:
    if action == player_action and _is_active:
        emit_signal('control_remapped', player_action)
