extends VBoxContainer
class_name Menu

signal menu_changed(new_menu, metadata)
signal previous_menu_requested(metadata)
signal menu_navigated

var _last_mouse_focused_node: Control = null
var _default_focusable_node: Control = null

# The possible menus that the player can navigate to in various contexts, such
# as from the title screen or after pressing the pause button.
enum Menus {
    # Reserved for representing the unpaused state, in order to know when to
    # toggle visibility of the main pause menu and actually pause the game.
    UNPAUSED,

    # Reserved for indicating that we want to go back to the previous menu.
    PREVIOUS,

    MAIN,
    SAVE_SLOTS,
    SAVE_SLOT_ERROR,
    DELETE_CONFIRMATION,
    PAUSE,
    OPTIONS,
    INFO,
    QUIT,

    GAME_OPTIONS,
    AUDIO_OPTIONS,
    VIDEO_OPTIONS,
    CONTROLLER_OPTIONS,
    KEYBOARD_OPTIONS,
}

# Called when this menu is entered.
func enter(previous_menu: int, metadata: Dictionary) -> void:
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
    advance_to_menu_with_metadata(new_menu, {})

# Convenience function for emitting the menu_changed signal from within a menu.
# This version allows for specifying additional metadata to be passed to the
# new menu.
func advance_to_menu_with_metadata(new_menu: int, metadata: Dictionary) -> void:
    emit_signal('menu_changed', new_menu, metadata)

# Convenience function for emitting the previous_menu_requested signal from
# within a menu.
func go_to_previous_menu() -> void:
    go_to_previous_menu_with_metadata({})

# Convenience function for emitting the previous_menu_requested signal from
# within a menu. This version allows for specifying additional metadata to be
# passed to the previous menu.
func go_to_previous_menu_with_metadata(metadata: Dictionary) -> void:
    emit_signal('previous_menu_requested', metadata)

# Convenience function for emitting the menu_navigated signal from within a
# menu. This signal is used to emit the click sound when navigating the various
# menus.
func emit_menu_navigation_sound() -> void:
    emit_signal('menu_navigated')

func set_focus_signals_enabled_for_nodes(nodes: Array, enabled: bool) -> void:
    var method := 'connect' if enabled else 'disconnect'
    for node in nodes:
        node.call(method, 'focus_entered', self, 'emit_menu_navigation_sound')

func connect_mouse_entered_signals_to_menu(nodes: Array) -> void:
    for node in nodes:
        node.connect('mouse_entered', self, '_on_mouse_entered', [node])

func get_last_mouse_focused_node() -> Control:
    return _last_mouse_focused_node

func set_default_focusable_node(node: Control) -> void:
    _default_focusable_node = node
func get_default_focusable_node() -> Control:
    return _default_focusable_node

func _on_mouse_entered(new_mouse_focus_node: Control) -> void:
    _last_mouse_focused_node = new_mouse_focus_node

    emit_menu_navigation_sound()
