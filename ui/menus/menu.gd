extends VBoxContainer
class_name Menu

signal menu_changed(old_menu, new_menu)
signal menu_navigated

# The possible menus that the player can navigate to in various contexts, such
# as from the title screen or after pressing the pause button.
enum Menus {
    # Reserved for representing the unpaused state, in order to know when to
    # toggle visibility of the main pause menu and actually pause the game.
    UNPAUSED,

    PAUSE,
    OPTIONS,
    QUIT,

    AUDIO_OPTIONS,
    VIDEO_OPTIONS,
    CONTROLLER_OPTIONS,
}

# Called when this menu is entered.
func enter(previous_menu: int) -> void:
    pass

# Called when this menu is exited.
func exit() -> void:
    pass

# Called when handling input for this menu.
func handle_input(event: InputEvent) -> void:
    pass

# Convenience function for emitting the menu_changed signal from within a menu.
func change_menu(old_menu: int, new_menu: int) -> void:
    emit_signal('menu_changed', old_menu, new_menu)

# Convenience function for emitting the menu_navigated signal from within a
# menu. This signal is used to emit the click sound when navigating the various
# menus.
func emit_menu_navigation_sound() -> void:
    emit_signal('menu_navigated')
