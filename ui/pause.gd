extends Control
class_name Pause

signal quit_to_main_menu_requested
signal quit_to_desktop_requested

onready var MENUS = {
    Menu.Menus.UNPAUSED: $MenuBackground/UnpausedState,

    Menu.Menus.PAUSE:   $MenuBackground/PauseMenu,
    Menu.Menus.OPTIONS: $MenuBackground/OptionsMenu,
    Menu.Menus.QUIT:    $MenuBackground/QuitMenu,

    Menu.Menus.GAME_OPTIONS:       $MenuBackground/GameOptionsMenu,
    Menu.Menus.AUDIO_OPTIONS:      $MenuBackground/AudioOptionsMenu,
    Menu.Menus.VIDEO_OPTIONS:      $MenuBackground/VideoOptionsMenu,
    Menu.Menus.CONTROLLER_OPTIONS: $MenuBackground/ControllerOptionsMenu,
    Menu.Menus.KEYBOARD_OPTIONS:   $MenuBackground/KeyboardOptionsMenu,
}
var _menu_stack := []

onready var _ui_sound_player: Node = $UiSoundPlayer
onready var _black_overlay: ColorRect = $BlackOverlay

func _ready() -> void:
    _set_quit_menu_input_enabled(true)

    # Intercept all menu_changed signals from individual submenus.
    for menu in MENUS.values():
        menu.connect('menu_changed', self, '_on_menu_changed')
        menu.connect('previous_menu_requested', self, '_on_previous_menu_requested')
        menu.connect('menu_navigated', _ui_sound_player, 'play_ui_navigation_sound')

    MENUS[Menu.Menus.UNPAUSED].connect('pause_changed', self, '_set_paused')
    MENUS[Menu.Menus.QUIT].connect(
        'quit_to_main_menu_requested', self, '_on_quit_to_main_menu_requested')
    MENUS[Menu.Menus.QUIT].connect(
        'quit_to_desktop_requested', self, '_on_quit_to_desktop_requested')

    Controls.connect('mode_changed', self, '_on_control_mode_changed')

    # Start in unpaused state.
    _change_menu(Menu.Menus.UNPAUSED, Menu.Menus.UNPAUSED, {})

    Options.load_options_and_report_errors()

func _input(event: InputEvent) -> void:
    MENUS[_menu_stack.back()].handle_input(event)

func _change_menu(old_menu: int, new_menu: int, metadata: Dictionary) -> void:
    # All inputs while paused should not be propagated out of the pause menu to
    # things like the player controller, dialog boxes, etc.
    #
    # TODO: This doesn't work when placed after the handle_input() call in the
    #       _input() method above, see if you can figure out why. The issue is
    #       that using the dpad to navigate the menu no longer works in that
    #       case.
    if get_tree().paused:
        accept_event()

    # Use a basic pushdown automaton to control menu transitions. The logic here
    # can be simplified because, in the case of menus, we always either push the
    # new menu on the stack to go forwards, or pop the current menu from the
    # stack to go backwards. The only exception is unpausing, which will always
    # reset the stack to just be the unpaused state, since this can happen from
    # any submenu.
    MENUS[old_menu].exit()
    match new_menu:
        Menu.Menus.UNPAUSED:
            _menu_stack = [new_menu]
        Menu.Menus.PREVIOUS:
            _menu_stack.pop_back()
        _:
            _menu_stack.push_back(new_menu)
    MENUS[_menu_stack.back()].enter(old_menu, metadata)

func _set_quit_menu_input_enabled(enabled: bool) -> void:
    set_process_input(enabled)
    MENUS[Menu.Menus.QUIT].set_input_enabled(enabled)

func _on_menu_changed(new_menu: int, metadata: Dictionary) -> void:
    _change_menu(_menu_stack.back(), new_menu, metadata)

func _on_previous_menu_requested(metadata: Dictionary) -> void:
    assert(_menu_stack.size() >= 2)
    _change_menu(_menu_stack.back(), Menu.Menus.PREVIOUS, metadata)

func _on_quit_to_main_menu_requested() -> void:
    _set_quit_menu_input_enabled(false)

    emit_signal('quit_to_main_menu_requested')

func _on_quit_to_desktop_requested() -> void:
    emit_signal('quit_to_desktop_requested')

func _on_control_mode_changed(new_mode: int) -> void:
    assert(new_mode in [Controls.Mode.CONTROLLER, Controls.Mode.KEYBOARD])

    if not get_tree().paused:
        return

    match new_mode:
        Controls.Mode.CONTROLLER:
            MouseCursor.set_mouse_mode(MouseCursor.MouseMode.HIDDEN)

        Controls.Mode.KEYBOARD:
            MouseCursor.set_mouse_mode(MouseCursor.MouseMode.VISIBLE)

func _set_paused(new_pause_state: bool) -> void:
    get_tree().paused = new_pause_state

    _black_overlay.visible = new_pause_state

    # Need to call this callback manually here, see related comment in
    # title_screen.gd.
    _on_control_mode_changed(Controls.get_mode())
