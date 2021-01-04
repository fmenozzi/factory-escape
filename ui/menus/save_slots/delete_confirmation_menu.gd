extends 'res://ui/menus/menu.gd'

signal delete_succeeded(save_slot)

onready var _delete_this_save_slot: Label = $DeleteThisSaveSlot
onready var _yes: Button = $Yes
onready var _no: Button = $No

onready var _focusable_nodes := [
    _yes,
    _no,
]

var _save_slot: int = -1

func _ready() -> void:
    _yes.connect('pressed', self, '_on_yes_pressed')
    _no.connect('pressed', self, '_on_no_pressed')

func enter(previous_menu: int, metadata: Dictionary) -> void:
    self.visible = true

    assert('save_slot' in metadata)
    _save_slot = metadata['save_slot']
    assert(_save_slot in [
        SaveAndLoad.SaveSlot.SLOT_1,
        SaveAndLoad.SaveSlot.SLOT_2,
        SaveAndLoad.SaveSlot.SLOT_3,
    ])

    _delete_this_save_slot.text = 'Delete Save Slot %d?' % _save_slot

    _no.grab_focus()

    set_focus_signals_enabled_for_nodes(_focusable_nodes, true)

func exit() -> void:
    self.visible = false

    set_focus_signals_enabled_for_nodes(_focusable_nodes, false)

func handle_input(event: InputEvent) -> void:
    if event.is_action_pressed('ui_cancel'):
        go_to_previous_menu()

func _on_yes_pressed() -> void:
    var error_plus_message: ErrorPlusMessage = SaveAndLoad.delete_save_data(_save_slot)
    if error_plus_message.error != OK:
        advance_to_menu_with_metadata(Menu.Menus.SAVE_SLOT_ERROR, {
            'save_slot': _save_slot,
            'error': error_plus_message.error,
            'error_msg': error_plus_message.error_msg,
        })
    else:
        emit_signal('delete_succeeded', _save_slot)

        go_to_previous_menu()

func _on_no_pressed() -> void:
    go_to_previous_menu()
