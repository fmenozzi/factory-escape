extends 'res://ui/menus/menu.gd'

signal save_slot_selected(save_slot)

enum State {
    NORMAL,
    DELETE_CONFIRMATION,
}
var _state: int = State.NORMAL

onready var _slot_container_1: HBoxContainer = $SaveSlotContainer1
onready var _slot_container_2: HBoxContainer = $SaveSlotContainer2
onready var _slot_container_3: HBoxContainer = $SaveSlotContainer3

onready var _slot_container_1_button: Button = $SaveSlotContainer1/Slot

onready var _back: Button = $Back

func _ready() -> void:
    _slot_container_1.connect('slot_requested', self, '_on_slot_pressed', [SaveAndLoad.SaveSlot.SLOT_1])
    _slot_container_2.connect('slot_requested', self, '_on_slot_pressed', [SaveAndLoad.SaveSlot.SLOT_2])
    _slot_container_3.connect('slot_requested', self, '_on_slot_pressed', [SaveAndLoad.SaveSlot.SLOT_3])

    _slot_container_1.connect('delete_requested', self, '_on_delete_pressed', [SaveAndLoad.SaveSlot.SLOT_1])
    _slot_container_2.connect('delete_requested', self, '_on_delete_pressed', [SaveAndLoad.SaveSlot.SLOT_2])
    _slot_container_3.connect('delete_requested', self, '_on_delete_pressed', [SaveAndLoad.SaveSlot.SLOT_3])

    _back.connect('pressed', self, '_on_back_pressed')

func enter(previous_menu: int) -> void:
    self.visible = true

    _state = State.NORMAL

    _slot_container_1_button.grab_focus()

func exit() -> void:
    self.visible = false

func handle_input(event: InputEvent) -> void:
    if event.is_action_pressed('ui_up') or event.is_action_pressed('ui_down'):
        emit_menu_navigation_sound()

    if event.is_action_pressed('ui_cancel'):
        go_to_previous_menu()

func _on_slot_pressed(save_slot: int) -> void:
    emit_signal('save_slot_selected', save_slot)

func _on_delete_pressed(save_slot: int) -> void:
    pass

func _on_back_pressed() -> void:
    go_to_previous_menu()
