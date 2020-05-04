extends VBoxContainer

signal menu_changed(old_menu, new_menu)
signal menu_navigated

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
