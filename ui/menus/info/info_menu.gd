extends 'res://ui/menus/menu.gd'

onready var _credits: Button = $Credits
onready var _licenses: Button = $Licenses
onready var _back: Button = $Back

onready var _focusable_nodes := [
    _credits,
    _licenses,
    _back,
]

func _ready() -> void:
    _credits.connect('pressed', self, '_on_credits_pressed')
    _licenses.connect('pressed', self, '_on_licenses_pressed')
    _back.connect('pressed', self, '_on_back_pressed')

    set_input_enabled(true)

    connect_mouse_entered_signals_to_menu(_focusable_nodes)
    set_default_focusable_node(_credits)

    _copy_licenses_file_to_user()

func enter(previous_menu: int, metadata: Dictionary) -> void:
    self.visible = true

    if Controls.get_mode() == Controls.Mode.CONTROLLER:
        get_default_focusable_node().grab_focus()

    set_focus_signals_enabled_for_nodes(_focusable_nodes, true)

func exit() -> void:
    self.visible = false

    set_focus_signals_enabled_for_nodes(_focusable_nodes, false)

func handle_input(event: InputEvent) -> void:
    if event.is_action_pressed('ui_cancel'):
        go_to_previous_menu()

func set_input_enabled(enabled: bool) -> void:
    _set_focus_enabled(enabled)

    if enabled:
        _credits.connect('pressed', self, '_on_credits_pressed')
        _licenses.connect('pressed', self, '_on_licenses_pressed')
        _back.connect('pressed', self, '_on_back_pressed')
    else:
        _credits.disconnect('pressed', self, '_on_credits_pressed')
        _licenses.disconnect('pressed', self, '_on_licenses_pressed')
        _back.disconnect('pressed', self, '_on_back_pressed')

func _set_focus_enabled(enabled: bool) -> void:
    for node in _focusable_nodes:
        if enabled:
            node.focus_mode = Control.FOCUS_ALL
            node.mouse_filter = Control.MOUSE_FILTER_PASS
        else:
            node.focus_mode = Control.FOCUS_NONE
            node.mouse_filter = Control.MOUSE_FILTER_IGNORE

# Since we can't read from res:// in exported projects, we need to first copy
# the license file in res:// to user:// so that we can open that file below.
#
# TODO: See if there's a way to package licenses.txt directly in user:// on
#       export.
func _copy_licenses_file_to_user() -> void:
    var res_file := File.new()
    var error := res_file.open('res://ui/menus/info/data/licenses.txt', File.READ)
    if error != OK:
        return
    var license_text := res_file.get_as_text()
    var user_file := File.new()
    error = user_file.open('user://licenses.txt', File.WRITE)
    if error != OK:
        res_file.close()
        return
    user_file.store_string(license_text)
    user_file.close()
    res_file.close()

func _on_credits_pressed() -> void:
    # Disable input in order to prevent navigating menus during the screen
    # fadeout. Note that we have to disable input/focus both here and in the
    # title screen itself.
    #
    # TODO: Make this cleaner (i.e. no chained get_parent() calls).
    set_input_enabled(false)
    get_parent().get_parent().set_process_input(false)

    var fade_duration := 2.0
    SceneChanger.change_scene_to(Preloads.CreditsScreen, fade_duration)

func _on_licenses_pressed() -> void:
    # TODO: Perhaps a submenu for confirmation that this will open in a new
    #       window would be a good idea.
    OS.shell_open(ProjectSettings.globalize_path("user://licenses.txt"))

func _on_back_pressed() -> void:
    go_to_previous_menu()
