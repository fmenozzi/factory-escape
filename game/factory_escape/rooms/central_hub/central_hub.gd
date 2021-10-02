extends Room
class_name CentralHub

signal boss_fight_triggered

onready var _camera_focus_point: CameraFocusPoint = $CameraFocusPoint
onready var _fragile_platform: FragilePlatform = $BossFight/FragilePlatform
onready var _left_wall_collision_shape: CollisionShape2D = $BossFight/Walls/Left/CollisionShape2D
onready var _right_wall_collision_shape: CollisionShape2D = $BossFight/Walls/Right/CollisionShape2D
onready var _left_trigger: Area2D = $BossFight/Triggers/Left
onready var _right_trigger: Area2D = $BossFight/Triggers/Right
onready var _left_trigger_collision_shape: CollisionShape2D = $BossFight/Triggers/Left/CollisionShape2D
onready var _right_trigger_collision_shape: CollisionShape2D = $BossFight/Triggers/Right/CollisionShape2D
onready var _save_manager: CentralHubSaveManager = $SaveManager

func _ready() -> void:
    _left_trigger.connect('body_entered', self, '_on_player_triggered_boss_fight')
    _right_trigger.connect('body_entered', self, '_on_player_triggered_boss_fight')

func set_enable_boss_fight_walls(enabled: bool) -> void:
    _left_wall_collision_shape.set_deferred('disabled', not enabled)
    _right_wall_collision_shape.set_deferred('disabled', not enabled)

func set_enable_boss_fight_triggers(enabled: bool) -> void:
    _left_trigger_collision_shape.set_deferred('disabled', not enabled)
    _right_trigger_collision_shape.set_deferred('disabled', not enabled)

func get_camera_focus_point() -> CameraFocusPoint:
    return _camera_focus_point

func get_fragile_platform() -> FragilePlatform:
    return _fragile_platform

func _on_player_triggered_boss_fight(player: Player) -> void:
    if not player:
        return

    if _save_manager.warden_fight_state == CentralHubSaveManager.WardenFightState.POST_FIGHT:
        return

    _save_manager.warden_fight_state = CentralHubSaveManager.WardenFightState.FIGHT

    set_enable_boss_fight_triggers(false)

    emit_signal('boss_fight_triggered')
