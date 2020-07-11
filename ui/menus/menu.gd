extends VBoxContainer
class_name Menu

signal menu_changed( new_menu)
signal previous_menu_requested
signal menu_navigated

# The possible menus that the player can navigate to in various contexts, such
# as from the title screen or after pressing the pause button.
enum Menus {
    # Reserved for representing the unpaused state, in order to know when to
    # toggle visibility of the main pause menu and actually pause the game.
    UNPAUSED,

    # Reserved for indicating that we want to go back to the previous menu.
    PREVIOUS,

    MAIN,
    PAUSE,
    OPTIONS,
    QUIT,

    AUDIO_OPTIONS,
    VIDEO_OPTIONS,
    CONTROLLER_OPTIONS,
    KEYBOARD_OPTIONS,
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

# Toggle whether inputs for this menu should be enabled. This function is meant
# to be overridden by individual menus so that they can e.g. enable/disable
# individual button callbacks.
func set_input_enabled(enabled: bool) -> void:
    pass

# Convenience function for emitting the menu_changed signal from within a menu.
func advance_to_menu(new_menu: int) -> void:
    emit_signal('menu_changed', new_menu)

# Convenience function for emitting the previous_menu_requested signal from
# within a menu.
func go_to_previous_menu() -> void:
    emit_signal('previous_menu_requested')

# Convenience function for emitting the menu_navigated signal from within a
# menu. This signal is used to emit the click sound when navigating the various
# menus.
func emit_menu_navigation_sound() -> void:
    emit_signal('menu_navigated')
