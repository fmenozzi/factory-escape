extends 'res://ui/menus/menu.gd'

signal save_slot_selected(save_slot)

onready var _slot_container_1: HBoxContainer = $SaveSlotContainer1
onready var _slot_container_2: HBoxContainer = $SaveSlotContainer2
onready var _slot_container_3: HBoxContainer = $SaveSlotContainer3

onready var _slot_container_1_button: Button = $SaveSlotContainer1/Slot

onready var _back: Button = $Back

func _ready() -> void:
    _slot_container_1.connect('slot_requested', self, '_on_slot_pressed')
    _slot_container_2.connect('slot_requested', self, '_on_slot_pressed')
    _slot_container_3.connect('slot_requested', self, '_on_slot_pressed')

    _slot_container_1.connect('delete_requested', self, '_on_delete_pressed')
    _slot_container_2.connect('delete_requested', self, '_on_delete_pressed')
    _slot_container_3.connect('delete_requested', self, '_on_delete_pressed')

    _back.connect('pressed', self, '_on_back_pressed')

func enter(previous_menu: int, metadata: Dictionary) -> void:
    self.visible = true

    _slot_container_1.set_save_slot_label()
    _slot_container_2.set_save_slot_label()
    _slot_container_3.set_save_slot_label()

    _slot_container_1_button.grab_focus()

func exit() -> void:
    self.visible = false

func handle_input(event: InputEvent) -> void:
    if event.is_action_pressed('ui_up') or event.is_action_pressed('ui_down'):
        emit_menu_navigation_sound()

    if event.is_action_pressed('ui_cancel'):
        go_to_previous_menu()

func _on_slot_pressed(save_slot: int, error: int, error_msg: String) -> void:
    if error != OK:
        advance_to_menu_with_metadata(Menu.Menus.SAVE_SLOT_ERROR, {
            'error': error,
            'error_msg': error_msg,
        })
    else:
        emit_signal('save_slot_selected', save_slot)

func _on_delete_pressed(save_slot: int) -> void:
    advance_to_menu_with_metadata(Menu.Menus.DELETE_CONFIRMATION, {
        'save_slot': save_slot,
    })

func _on_back_pressed() -> void:
    go_to_previous_menu()
