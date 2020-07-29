tool
extends Control

# The actual game scene to switch to once the player starts the game. This is an
# instance of Game.tscn.
export(PackedScene) var game = null

onready var MENUS := {
    Menu.Menus.MAIN:                $MenuBackground/MainMenu,
    Menu.Menus.SAVE_SLOTS:          $MenuBackground/SaveSlotsMenu,
    Menu.Menus.DELETE_CONFIRMATION: $MenuBackground/DeleteConfirmationMenu,
    Menu.Menus.OPTIONS:             $MenuBackground/OptionsMenu,
    Menu.Menus.QUIT:                $MenuBackground/MainQuitMenu,

    Menu.Menus.AUDIO_OPTIONS:      $MenuBackground/AudioOptionsMenu,
    Menu.Menus.VIDEO_OPTIONS:      $MenuBackground/VideoOptionsMenu,
    Menu.Menus.CONTROLLER_OPTIONS: $MenuBackground/ControllerOptionsMenu,
    Menu.Menus.KEYBOARD_OPTIONS:   $MenuBackground/KeyboardOptionsMenu,
}
var _menu_stack := []

onready var _click_sound: AudioStreamPlayer = $ClickSound
onready var _saving_indicator: Control = $SavingIndicator

func _get_configuration_warning() -> String:
    if game == null:
        return 'No instance of Game.tscn set in title screen!'
    if game.instance().run_standalone:
        return 'Instance of Game.tscn must not be in run_standalone mode!'
    return ''

func _ready() -> void:
    assert(game != null)
    assert(not game.instance().run_standalone)

    _set_main_menu_input_enabled(true)

    # Intercept all menu-related signals from individual submenus.
    for menu in MENUS.values():
        menu.connect('menu_changed', self, '_on_menu_changed')
        menu.connect('previous_menu_requested', self, '_on_previous_menu_requested')
        menu.connect('menu_navigated', self, '_emit_click_sound')

    MENUS[Menu.Menus.SAVE_SLOTS].connect('save_slot_selected', self, '_start_game')

    Options.connect('options_saved', self, '_on_options_saved')

    # Start at main menu.
    _change_menu(Menu.Menus.MAIN, Menu.Menus.MAIN, {})

    Options.load_options()

func _input(event: InputEvent) -> void:
    MENUS[_menu_stack.back()].handle_input(event)

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
    MENUS[_menu_stack.back()].enter(old_menu, metadata)

func _set_main_menu_input_enabled(enabled: bool) -> void:
    set_process_input(enabled)
    MENUS[Menu.Menus.MAIN].set_input_enabled(enabled)

func _on_options_saved() -> void:
    if _saving_indicator.is_spinning():
        return

    _saving_indicator.start_spinning_for(1.0)

func _on_menu_changed(new_menu: int, metadata: Dictionary) -> void:
    _change_menu(_menu_stack.back(), new_menu, metadata)

func _on_previous_menu_requested() -> void:
    assert(_menu_stack.size() >= 2)
    _change_menu(_menu_stack.back(), Menu.Menus.PREVIOUS, {})

func _start_game(save_slot: int) -> void:
    _set_main_menu_input_enabled(false)

    # Set the save slot to use for this session.
    SaveAndLoad.save_slot = save_slot

    var fade_duration := 2.0
    SceneChanger.change_scene_to(game, fade_duration)

func _emit_click_sound() -> void:
    _click_sound.play()
