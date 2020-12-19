extends Node
class_name TutorialMessageTriggerSaveManager

onready var _tutorial_message_trigger = get_parent()
onready var _save_key: String = get_parent().get_path()

var player_entered := false

func get_save_data() -> Array:
    return [_save_key, {
        'player_entered': player_entered,
    }]

func load_save_data(all_save_data: Dictionary) -> void:
    if not _save_key in all_save_data:
        return

    var trigger_save_data: Dictionary = all_save_data[_save_key]
    assert('player_entered' in trigger_save_data)

    player_entered = trigger_save_data['player_entered']

    if player_entered:
        _tutorial_message_trigger.disconnect(
            'body_entered', _tutorial_message_trigger, '_on_player_entered')
        _tutorial_message_trigger.disconnect(
            'body_exited', _tutorial_message_trigger, '_on_player_exited')
