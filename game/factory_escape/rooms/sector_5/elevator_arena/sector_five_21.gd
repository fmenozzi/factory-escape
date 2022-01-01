extends Room

const SCROLL_SPEED_UV := 0.15

onready var _background: Sprite = $ScrollingBackground
onready var _arena: ElevatorArena = $ElevatorArena

var _shader_manager := ShaderManager.new()
var _active := false
var _offset_uv := 0.0

func _ready() -> void:
    _shader_manager.set_object(_background)
    stop()

func _process(delta: float) -> void:
    _offset_uv = wrapf(_offset_uv + SCROLL_SPEED_UV * delta, 0.0, 1.0)
    _shader_manager.set_shader_param('offset_uv', _offset_uv)

func start_background_scrolling() -> void:
    _active = true
    set_process(true)
    _shader_manager.add_shader(Preloads.ScrollShader, _background)

func start_arena() -> void:
    _arena.start()

func stop() -> void:
    _offset_uv = 0.0
    _active = false
    set_process(false)
    _shader_manager.clear_shader()

func set_background_scrolling_paused(paused: bool) -> void:
    if _active:
        set_process(not paused)

func lamp_reset() -> void:
    stop()
