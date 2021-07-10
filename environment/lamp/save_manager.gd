extends Node
class_name LampSaveManager

var is_lit := false

onready var _lamp = get_parent()
onready var _save_key: String = get_parent().get_path()

func get_save_data() -> Array:
    return [_save_key, {
        'is_lit': is_lit
    }]

func load_version_0_1_0(all_save_data: Dictionary) -> void:
    if not _save_key in all_save_data:
        return

    var lamp_save_data: Dictionary = all_save_data[_save_key]
    assert('is_lit' in lamp_save_data)

    is_lit = lamp_save_data['is_lit']

    if is_lit:
        _lamp._embers.emitting = true
        _lamp._animation_player.play('lit')
        _lamp._fade_in_out_label.set_text('Rest')
        _lamp._fire_sound.play()
