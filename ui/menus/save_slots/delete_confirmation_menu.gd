extends 'res://ui/menus/menu.gd'

onready var _delete_this_save_slot: Label = $DeleteThisSaveSlot
onready var _yes: Button = $Yes
onready var _no: Button = $No

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

func exit() -> void:
    self.visible = false

func handle_input(event: InputEvent) -> void:
    if event.is_action_pressed('ui_up') or event.is_action_pressed('ui_down'):
        emit_menu_navigation_sound()

    if event.is_action_pressed('ui_cancel'):
        go_to_previous_menu()

func _on_yes_pressed() -> void:
    SaveAndLoad.delete_save_data(_save_slot)

    go_to_previous_menu()

func _on_no_pressed() -> void:
    go_to_previous_menu()
