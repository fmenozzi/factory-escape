extends HBoxContainer

signal slot_requested
signal delete_requested

export(int, 1, 3) var save_slot := 1

onready var _slot: Button = $Slot
onready var _delete: Button = $Delete

func _ready() -> void:
    assert(save_slot in [1, 2, 3])

    if SaveAndLoad.has_save_data(save_slot):
        _slot.text = 'Slot %d' % save_slot
    else:
        _slot.text = 'EMPTY'

    _slot.connect('pressed', self, '_on_slot_button_pressed')
    _delete.connect('pressed', self, '_on_delete_button_pressed')

func _on_slot_button_pressed() -> void:
    emit_signal('slot_requested')

func _on_delete_button_pressed() -> void:
    emit_signal('delete_requested')
