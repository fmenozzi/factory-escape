extends Position2D
class_name CameraFocusPoint

export(float) var pan_time := 0.5

onready var _trigger_area: Area2D = $TriggerArea

var _is_active := false

func _ready() -> void:
    set_active(_is_active)

func set_active(active: bool) -> void:
    _is_active = active

    if _is_active:
        _trigger_area.connect('body_entered', self, '_on_player_entered')
        _trigger_area.connect('body_exited', self, '_on_player_exited')
    else:
        _trigger_area.disconnect('body_entered', self, '_on_player_entered')
        _trigger_area.disconnect('body_exited', self, '_on_player_exited')

func _on_player_entered(player: Player) -> void:
    if not player:
        return

    player.get_camera().detach_and_move_to_global(global_position, pan_time)

func _on_player_exited(player: Player) -> void:
    if not player:
        return

    player.get_camera().reattach(pan_time)
