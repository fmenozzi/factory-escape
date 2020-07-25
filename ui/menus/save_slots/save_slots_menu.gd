extends 'res://ui/menus/menu.gd'

signal save_slot_selected(save_slot)

onready var _slot_1: Button = $Slot1
onready var _slot_2: Button = $Slot2
onready var _slot_3: Button = $Slot3

func _ready() -> void:
    _slot_1.connect('pressed', self, '_on_slot_pressed', [SaveAndLoad.SaveSlot.SLOT_1])
    _slot_2.connect('pressed', self, '_on_slot_pressed', [SaveAndLoad.SaveSlot.SLOT_2])
    _slot_3.connect('pressed', self, '_on_slot_pressed', [SaveAndLoad.SaveSlot.SLOT_3])

func enter(previous_menu: int) -> void:
    self.visible = true

    _slot_1.grab_focus()

func exit() -> void:
    self.visible = false

func handle_input(event: InputEvent) -> void:
    if event.is_action_pressed('ui_up') or event.is_action_pressed('ui_down'):
        emit_menu_navigation_sound()

func _on_slot_pressed(save_slot: int) -> void:
    emit_signal('save_slot_selected', save_slot)
