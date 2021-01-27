extends CanvasLayer

enum MouseMode {
    VISIBLE,
    HIDDEN,
}
var _mouse_mode: int
var _should_show_custom_cursor: bool

onready var _cursor: Sprite = $Sprite

func _ready() -> void:
    # We want the ACTUAL cursor to be hidden at all times.
    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

    set_mouse_mode(MouseMode.HIDDEN)

func _process(delta: float) -> void:
    _cursor.position = _cursor.get_global_mouse_position()
    _cursor.visible = _should_show_custom_cursor

func set_mouse_mode(mouse_mode: int) -> void:
    assert(mouse_mode in [MouseMode.VISIBLE, MouseMode.HIDDEN])

    _mouse_mode = mouse_mode
    _should_show_custom_cursor = (_mouse_mode == MouseMode.VISIBLE)
