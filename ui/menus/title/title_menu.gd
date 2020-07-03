extends 'res://ui/menus/menu.gd'

signal start_pressed

onready var _start: Button = $Start
onready var _options: Button = $Options
onready var _quit: Button = $Quit

func _ready() -> void:
    _start.connect('pressed', self, '_on_start_pressed')
    _options.connect('pressed', self, '_on_options_pressed')
    _quit.connect('pressed', self, '_on_quit_pressed')

func enter(previous_menu: int) -> void:
    self.visible = true

    match previous_menu:
        Menu.Menus.OPTIONS:
            _options.grab_focus()
        Menu.Menus.QUIT:
            _quit.grab_focus()
        _:
            _start.grab_focus()

func exit() -> void:
    self.visible = false

func handle_input(event: InputEvent) -> void:
    if event.is_action_pressed('ui_up') or event.is_action_pressed('ui_down'):
        emit_menu_navigation_sound()

func _on_start_pressed() -> void:
    emit_signal('start_pressed')

func _on_options_pressed() -> void:
    advance_to_menu(Menu.Menus.OPTIONS)

func _on_quit_pressed() -> void:
    advance_to_menu(Menu.Menus.QUIT)
