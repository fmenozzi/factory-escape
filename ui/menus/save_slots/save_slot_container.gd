extends HBoxContainer

signal slot_requested(save_slot, error, error_msg)
signal delete_requested(save_slot)

export(int, 1, 3) var save_slot := 1

var error := OK
var error_msg := ''

enum SlotMode {
    EMPTY,
    INVALID,
    USED,
}

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

func reset_save_slot() -> void:
    _set_slot_mode(SlotMode.EMPTY)

func set_save_slot_label() -> void:
    if not SaveAndLoad.has_save_data(save_slot):
        _set_slot_mode(SlotMode.EMPTY)
        return

    # Note that we're not actually going to be calling any node-specific loading
    # functions here, since those nodes don't exist in this scene tree. This is
    # essentially a way to check that loading the data from disk succeeded and
    # that the save file version is valid.
    SaveAndLoad.save_slot = save_slot
    var error_plus_message: ErrorPlusMessage = SaveAndLoad.load_game()
    SaveAndLoad.save_slot = SaveAndLoad.SaveSlot.UNSET
    if error_plus_message.error != OK:
        _set_slot_mode(SlotMode.INVALID, error_plus_message)
        return

    _set_slot_mode(SlotMode.USED)

func _set_slot_mode(mode: int, error_plus_message: ErrorPlusMessage = null) -> void:
    assert(mode in [SlotMode.EMPTY, SlotMode.INVALID, SlotMode.USED])

    match mode:
        SlotMode.EMPTY:
            _slot.text = 'EMPTY'
            _slot.modulate = Color.white

            _delete.disabled = true

            error = OK
            error_msg = ''

        SlotMode.INVALID:
            _slot.text = 'INVALID SAVE DATA'
            _slot.modulate = Color('#ff4f78')

            _delete.disabled = false

            assert(error_plus_message != null)
            error = error_plus_message.error
            error_msg = error_plus_message.error_msg

        SlotMode.USED:
            _slot.text = 'Slot %d' % save_slot
            _slot.modulate = Color.white

            _delete.disabled = false

            error = OK
            error_msg = ''

func _on_slot_button_pressed() -> void:
    emit_signal('slot_requested', save_slot, error, error_msg)

func _on_delete_button_pressed() -> void:
    emit_signal('delete_requested', save_slot)
