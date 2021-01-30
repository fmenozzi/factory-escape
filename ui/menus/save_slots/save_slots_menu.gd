extends 'res://ui/menus/menu.gd'

signal save_slot_selected(save_slot)

onready var _slot_container_1: HBoxContainer = $SaveSlotContainer1
onready var _slot_container_2: HBoxContainer = $SaveSlotContainer2
onready var _slot_container_3: HBoxContainer = $SaveSlotContainer3

onready var _slot_container_1_button: Button = $SaveSlotContainer1/Slot
onready var _slot_container_2_button: Button = $SaveSlotContainer2/Slot
onready var _slot_container_3_button: Button = $SaveSlotContainer3/Slot

onready var _slot_container_1_delete: Button = $SaveSlotContainer1/Delete
onready var _slot_container_2_delete: Button = $SaveSlotContainer2/Delete
onready var _slot_container_3_delete: Button = $SaveSlotContainer3/Delete

onready var _back: Button = $Back

onready var _focusable_nodes := [
    _slot_container_1_button,
    _slot_container_2_button,
    _slot_container_3_button,
    _slot_container_1_delete,
    _slot_container_2_delete,
    _slot_container_3_delete,
    _back,
]

func _ready() -> void:
    _slot_container_1.connect('slot_requested', self, '_on_slot_pressed')
    _slot_container_2.connect('slot_requested', self, '_on_slot_pressed')
    _slot_container_3.connect('slot_requested', self, '_on_slot_pressed')

    _slot_container_1.connect('delete_requested', self, '_on_delete_pressed')
    _slot_container_2.connect('delete_requested', self, '_on_delete_pressed')
    _slot_container_3.connect('delete_requested', self, '_on_delete_pressed')

    _back.connect('pressed', self, '_on_back_pressed')

    connect_mouse_entered_signals_to_menu(_focusable_nodes)
    set_default_focusable_node(_slot_container_1_button)

func enter(previous_menu: int, metadata: Dictionary) -> void:
    self.visible = true

    _slot_container_1.set_save_slot_label()
    _slot_container_2.set_save_slot_label()
    _slot_container_3.set_save_slot_label()

    if Controls.get_mode() == Controls.Mode.CONTROLLER:
        match previous_menu:
            Menu.Menus.SAVE_SLOT_ERROR:
                assert('save_slot' in metadata)
                match metadata['save_slot']:
                    1:
                        _slot_container_1_button.grab_focus()
                    2:
                        _slot_container_2_button.grab_focus()
                    3:
                        _slot_container_3_button.grab_focus()
            _:
                get_default_focusable_node().grab_focus()

    set_focus_signals_enabled_for_nodes(_focusable_nodes, true)

func exit() -> void:
    self.visible = false

    set_focus_signals_enabled_for_nodes(_focusable_nodes, false)

func handle_input(event: InputEvent) -> void:
    if event.is_action_pressed('ui_cancel'):
        go_to_previous_menu()

func set_input_enabled(enabled: bool) -> void:
    _set_focus_enabled(enabled)

func _set_focus_enabled(enabled: bool) -> void:
    for node in _focusable_nodes:
        node.focus_mode = Control.FOCUS_ALL if enabled else Control.FOCUS_NONE

func _on_slot_pressed(save_slot: int, error: int, error_msg: String) -> void:
    if error != OK:
        advance_to_menu_with_metadata(Menu.Menus.SAVE_SLOT_ERROR, {
            'save_slot': save_slot,
            'error': error,
            'error_msg': error_msg,
        })
    else:
        emit_signal('save_slot_selected', save_slot)

func _on_delete_pressed(save_slot: int) -> void:
    advance_to_menu_with_metadata(Menu.Menus.DELETE_CONFIRMATION, {
        'save_slot': save_slot,
    })

func _on_delete_succeeded(save_slot: int) -> void:
    match save_slot:
        1:
            _slot_container_1.reset_save_slot()
        2:
            _slot_container_2.reset_save_slot()
        3:
            _slot_container_3.reset_save_slot()

func _on_back_pressed() -> void:
    go_to_previous_menu()
