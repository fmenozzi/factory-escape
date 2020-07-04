tool
extends Control

# The actual game scene to switch to once the player starts the game. This is an
# instance of Game.tscn.
export(PackedScene) var game = null

onready var MENUS := {
    Menu.Menus.MAIN:    $MenuBackground/MainMenu,
    Menu.Menus.OPTIONS: $MenuBackground/OptionsMenu,
    Menu.Menus.QUIT:    $MenuBackground/MainQuitMenu,

    Menu.Menus.AUDIO_OPTIONS:      $MenuBackground/AudioOptionsMenu,
    Menu.Menus.VIDEO_OPTIONS:      $MenuBackground/VideoOptionsMenu,
    Menu.Menus.CONTROLLER_OPTIONS: $MenuBackground/ControllerOptionsMenu,
}
var _menu_stack := []

func _get_configuration_warning() -> String:
    if game == null:
        return 'No instance of Game.tscn set in title screen!'
    return ''

func _ready() -> void:
    # Intercept all menu-changing-related signals from individual submenus.
    for menu in MENUS.values():
        menu.connect('menu_changed', self, '_on_menu_changed')
        menu.connect('previous_menu_requested', self, '_on_previous_menu_requested')

    MENUS[Menu.Menus.MAIN].connect('start_pressed', self, '_on_start_pressed')

    # Start at main menu.
    _change_menu(Menu.Menus.MAIN, Menu.Menus.MAIN)

func _input(event: InputEvent) -> void:
    MENUS[_menu_stack.back()].handle_input(event)

func _change_menu(old_menu: int, new_menu: int) -> void:
    # Use a basic pushdown automaton to control menu transitions. The logic here
    # can be simplified because, in the case of menus, we always either push the
    # new menu on the stack to go forwards, or pop the current menu from the
    # stack to go backwards.
    MENUS[old_menu].exit()
    if new_menu == Menu.Menus.PREVIOUS:
        _menu_stack.pop_back()
    else:
        _menu_stack.push_back(new_menu)
    MENUS[_menu_stack.back()].enter(old_menu)

func _on_menu_changed(new_menu: int) -> void:
    _change_menu(_menu_stack.back(), new_menu)

func _on_previous_menu_requested() -> void:
    assert(_menu_stack.size() >= 2)
    _change_menu(_menu_stack.back(), Menu.Menus.PREVIOUS)

func _on_start_pressed() -> void:
    var fade_duration := 2.0
    SceneChanger.change_scene_to(game, fade_duration)
