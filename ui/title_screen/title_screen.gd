tool
extends Control

# The actual game scene to switch to once the player starts the game. This is an
# instance of GameInterface.tscn.
export(PackedScene) var game = null

onready var MENUS := {
    Menu.Menus.MAIN:                $MenuBackground/MainMenu,
    Menu.Menus.SAVE_SLOTS:          $MenuBackground/SaveSlotsMenu,
    Menu.Menus.SAVE_SLOT_ERROR:     $MenuBackground/SaveSlotErrorMenu,
    Menu.Menus.DELETE_CONFIRMATION: $MenuBackground/DeleteConfirmationMenu,
    Menu.Menus.OPTIONS:             $MenuBackground/OptionsMenu,
    Menu.Menus.QUIT:                $MenuBackground/MainQuitMenu,

    Menu.Menus.GAME_OPTIONS:       $MenuBackground/GameOptionsMenu,
    Menu.Menus.AUDIO_OPTIONS:      $MenuBackground/AudioOptionsMenu,
    Menu.Menus.VIDEO_OPTIONS:      $MenuBackground/VideoOptionsMenu,
    Menu.Menus.CONTROLLER_OPTIONS: $MenuBackground/ControllerOptionsMenu,
    Menu.Menus.KEYBOARD_OPTIONS:   $MenuBackground/KeyboardOptionsMenu,
}
var _menu_stack := []

onready var _ui_sound_player: Node = $UiSoundPlayer
onready var _saving_indicator: Control = $SavingIndicator

func _get_configuration_warning() -> String:
    if game == null:
        return 'No instance of GameInterface.tscn set in title screen!'
    if game.instance().run_standalone:
        return 'Instance of GameInterface.tscn must not be in run_standalone mode!'
    return ''

func _ready() -> void:
    assert(game != null)
    assert(not game.instance().run_standalone)

    _set_main_menu_input_enabled(false)

    # Intercept all menu-related signals from individual submenus.
    for menu in MENUS.values():
        menu.connect('menu_changed', self, '_on_menu_changed')
        menu.connect('previous_menu_requested', self, '_on_previous_menu_requested')
        menu.connect('menu_navigated', _ui_sound_player, 'play_ui_navigation_sound')

    MENUS[Menu.Menus.SAVE_SLOTS].connect('save_slot_selected', self, '_start_game')
    MENUS[Menu.Menus.DELETE_CONFIRMATION].connect(
        'delete_succeeded', MENUS[Menu.Menus.SAVE_SLOTS], '_on_delete_succeeded')
    MENUS[Menu.Menus.QUIT].connect(
        'quit_to_desktop_requested', self, '_on_quit_to_desktop_requested')

    Options.connect('options_saved', self, '_on_options_saved')

    Options.load_options_and_report_errors()

    # Start at main menu once we finish transitioning to title screen.
    if SceneChanger.is_changing_scene():
        yield(SceneChanger, 'scene_changed')
    _set_main_menu_input_enabled(true)
    _change_menu(Menu.Menus.MAIN, Menu.Menus.MAIN, {})

    # This is slightly tricky. We want to do things like show/hide the custom
    # cursor whenever the control mode changes appropriately, but this callback
    # will only be called when the mode actually CHANGES. This means that if the
    # control mode is at KEYBOARD by the time we get here, moving the mouse won't
    # show the cursor until we first change the mode to CONTROLLER. Therefore,
    # we manually call the callback function with the current mode here.
    Controls.connect('mode_changed', self, '_on_control_mode_changed')
    _on_control_mode_changed(Controls.get_mode())

func _input(event: InputEvent) -> void:
    _get_current_menu().handle_input(event)

func _change_menu(old_menu: int, new_menu: int, metadata: Dictionary) -> void:
    # Use a basic pushdown automaton to control menu transitions. The logic here
    # can be simplified because, in the case of menus, we always either push the
    # new menu on the stack to go forwards, or pop the current menu from the
    # stack to go backwards.
    MENUS[old_menu].exit()
    if new_menu == Menu.Menus.PREVIOUS:
        _menu_stack.pop_back()
    else:
        _menu_stack.push_back(new_menu)
    _get_current_menu().enter(old_menu, metadata)

func _get_current_menu() -> Menu:
    assert(not _menu_stack.empty())

    return MENUS[_menu_stack.back()]

func _set_main_menu_input_enabled(enabled: bool) -> void:
    set_process_input(enabled)
    MENUS[Menu.Menus.MAIN].set_input_enabled(enabled)
    MENUS[Menu.Menus.SAVE_SLOTS].set_input_enabled(enabled)

func _on_options_saved() -> void:
    if _saving_indicator.is_spinning():
        return

    _saving_indicator.start_spinning_for(1.0)

func _on_menu_changed(new_menu: int, metadata: Dictionary) -> void:
    _change_menu(_menu_stack.back(), new_menu, metadata)

func _on_previous_menu_requested(metadata: Dictionary) -> void:
    assert(_menu_stack.size() >= 2)
    _change_menu(_menu_stack.back(), Menu.Menus.PREVIOUS, metadata)

func _on_quit_to_desktop_requested() -> void:
    _saving_indicator.start_spinning_for(0.0)

    Options.save_options_and_report_errors()

    get_tree().quit()

func _on_control_mode_changed(new_mode: int) -> void:
    assert(new_mode in [Controls.Mode.CONTROLLER, Controls.Mode.KEYBOARD])

    match new_mode:
        Controls.Mode.CONTROLLER:
            # In case we were in the middle of selecting an element in an
            # OptionButton when the control mode changed, close it so that it's
            # not visible while navigating the menu via controller.
            for option_button in get_tree().get_nodes_in_group('custom_option_button'):
                option_button.get_popup().hide()

            # Get the UI element that last had mouse focus and have it grab focus.
            var current_menu := _get_current_menu()
            var last_mouse_focused_node := current_menu.get_last_mouse_focused_node()
            if last_mouse_focused_node:
                last_mouse_focused_node.grab_focus()
            else:
                current_menu.get_default_focusable_node().grab_focus()

            MouseCursor.set_mouse_mode(MouseCursor.MouseMode.HIDDEN)

        Controls.Mode.KEYBOARD:
            # Get the currently-focused UI element and release its focus.
            var currently_focused_node := get_focus_owner()
            if currently_focused_node:
                currently_focused_node.release_focus()

            MouseCursor.set_mouse_mode(MouseCursor.MouseMode.VISIBLE)

func _start_game(save_slot: int) -> void:
    _set_main_menu_input_enabled(false)

    # Set the save slot to use for this session.
    SaveAndLoad.save_slot = save_slot

    var fade_duration := 2.0
    SceneChanger.change_scene_to(game, fade_duration)
