extends RoomFe

onready var _closing_door: StaticBody2D = $ClosingDoorSectorFive
onready var _pause_point: Position2D = $PausePoint
onready var _stopping_point: Position2D = $StoppingPoint
onready var _camera_trigger_area: Area2D = $CameraTrigger
onready var _stars: Sprite = $Stars

var _shader_manager: ShaderManager = ShaderManager.new()
var _elapsed_time := 0.0

func _ready() -> void:
    get_closing_door().set_opened()
    set_process(false)

    _shader_manager.set_object(_stars)
    _camera_trigger_area.connect('body_entered', self, '_start_parallax')

func _process(delta: float) -> void:
    var normalized_x_pos := _get_normalized_player_x_pos()
    var offset_uv := (1.0 - normalized_x_pos - 0.226882) * 0.15
    _shader_manager.set_shader_param('offset_uv', offset_uv)

func get_closing_door() -> StaticBody2D:
    return _closing_door

func get_pause_point() -> Position2D:
    return _pause_point

func get_stopping_point() -> Position2D:
    return _stopping_point

func _get_normalized_player_x_pos() -> float:
    return (Util.get_player().global_position - global_position).x / _stars.texture.get_width()

func _start_parallax(player: Player) -> void:
    if not player:
        return

    set_process(true)
