extends 'res://ui/menus/menu.gd'

onready var _resume: Button = $Resume
onready var _options: Button = $Options
onready var _quit: Button = $Quit

onready var _focusable_nodes := [
    _resume,
    _options,
    _quit,
]

func _ready() -> void:
    _resume.connect('pressed', self, '_on_resume_pressed')
    _options.connect('pressed', self, '_on_options_pressed')
    _quit.connect('pressed', self, '_on_quit_pressed')

func enter(previous_menu: int, metadata: Dictionary) -> void:
    self.visible = true

    match previous_menu:
        Menu.Menus.OPTIONS:
            _options.grab_focus()
        Menu.Menus.QUIT:
            _quit.grab_focus()
        _:
            _resume.grab_focus()

    set_focus_signals_enabled_for_nodes(_focusable_nodes, true)

func exit() -> void:
    self.visible = false

    set_focus_signals_enabled_for_nodes(_focusable_nodes, false)

func handle_input(event: InputEvent) -> void:
    if event.is_action_pressed('ui_pause') or event.is_action_pressed('ui_cancel'):
        advance_to_menu(Menu.Menus.UNPAUSED)

func _on_resume_pressed() -> void:
    advance_to_menu(Menu.Menus.UNPAUSED)

func _on_options_pressed() -> void:
    advance_to_menu(Menu.Menus.OPTIONS)

func _on_quit_pressed() -> void:
    advance_to_menu(Menu.Menus.QUIT)
