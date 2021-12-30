extends Room

onready var _background: Sprite = $ScrollingBackground

var _shader_manager := ShaderManager.new()

func _ready() -> void:
    _shader_manager.set_object(_background)
    _shader_manager.clear_shader()

func start_background_scrolling() -> void:
    _shader_manager.add_shader(Preloads.ScrollShader, _background)

func stop() -> void:
    _shader_manager.clear_shader()

func lamp_reset() -> void:
    stop()
