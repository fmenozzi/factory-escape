extends HBoxContainer

signal slot_requested(save_slot, error, error_msg)
signal delete_requested(save_slot)

export(int, 1, 3) var save_slot := 1

var error := OK
var error_msg := ''

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
        return

    # Note that we're not actually going to be calling any node-specific loading
    # functions here, since those nodes don't exist in this scene tree. This is
    # essentially a way to check that loading the data from disk succeeded and
    # that the save file version is valid.
    SaveAndLoad.save_slot = save_slot
    var error_plus_message: ErrorPlusMessage = SaveAndLoad.load_game()
    SaveAndLoad.save_slot = SaveAndLoad.SaveSlot.UNSET
    if error_plus_message.error != OK:
        error = error_plus_message.error
        error_msg = error_plus_message.error_msg
        _slot.text = 'INVALID SAVE DATA'
        _slot.modulate = Color('#ff4f78')
        return

    _slot.text = 'Slot %d' % save_slot

func _on_slot_button_pressed() -> void:
    emit_signal('slot_requested', save_slot, error, error_msg)

func _on_delete_button_pressed() -> void:
    emit_signal('delete_requested', save_slot)
