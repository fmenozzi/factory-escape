extends CanvasLayer

onready var _cursor: Sprite = $Sprite

func _ready() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(delta: float) -> void:
    _cursor.position = _cursor.get_global_mouse_position()
    _cursor.visible = _should_show_custom_cursor()

func _should_show_custom_cursor() -> bool:
    return Input.get_mouse_mode() == Input.MOUSE_MODE_HIDDEN
