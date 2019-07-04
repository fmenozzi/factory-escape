extends VBoxContainer

signal menu_changed(old_menu, new_menu)

# Called when this menu is entered.
func enter(pause: Pause, previous_menu: int) -> void:
    pass

# Called when this menu is exited.
func exit(pause: Pause) -> void:
    pass

# Called when handling input for this menu.
func handle_input(pause: Pause, event: InputEvent) -> void:
    pass

# Convenience function for emitting the menu_changed signal from within a menu.
func change_menu(old_menu: int, new_menu: int) -> void:
    emit_signal('menu_changed', old_menu, new_menu)