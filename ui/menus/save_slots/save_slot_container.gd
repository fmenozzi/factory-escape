extends HBoxContainer

signal slot_requested
signal delete_requested

export(int, 1, 3) var save_slot := 1

onready var _slot: Button = $Slot
onready var _delete: Button = $Delete

func _ready() -> void:
    assert(save_slot in [
        SaveAndLoad.SaveSlot.SLOT_1,
        SaveAndLoad.SaveSlot.SLOT_2,
        SaveAndLoad.SaveSlot.SLOT_3,
    ])

    set_save_slot_label()

    _slot.connect('pressed', self, '_on_slot_button_pressed')
    _delete.connect('pressed', self, '_on_delete_button_pressed')

func set_save_slot_label() -> void:
    if not SaveAndLoad.has_save_data(save_slot):
        _slot.text = 'EMPTY'
        _delete.disabled = true
    elif not SaveAndLoad.has_valid_version(save_slot):
        _slot.text = 'INVALID SAVE VERSION'
        _slot.disabled = true
        _delete.disabled = false
    else:
        _slot.text = 'Slot %d' % save_slot
        _delete.disabled = false

func _on_slot_button_pressed() -> void:
    emit_signal('slot_requested')

func _on_delete_button_pressed() -> void:
    emit_signal('delete_requested')
