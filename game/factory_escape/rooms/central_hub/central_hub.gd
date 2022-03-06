extends RoomFe
class_name CentralHub

signal boss_fight_triggered
signal player_entered_central_hub_shaft

onready var _central_lock: CentralLock = $CentralLock
onready var _camera_focus_point: CameraFocusPoint = $CameraFocusPoint
onready var _pre_warden_hard_save_areas: Array = $PreWardenHardSavePoints.get_children()
onready var _hard_save_area_1: Area2D = $PreWardenHardSavePoints/ToSectorOne
onready var _hard_save_area_2: Area2D = $PreWardenHardSavePoints/ToSectorTwo
onready var _hard_save_area_3: Area2D = $PreWardenHardSavePoints/ToSectorThree
onready var _hard_save_area_4: Area2D = $PreWardenHardSavePoints/ToSectorFour
onready var _door_area: Area2D = $BossFight/DoorArea
onready var _fragile_platform: FragilePlatform = $BossFight/FragilePlatform
onready var _left_wall_collision_shape: CollisionShape2D = $BossFight/Walls/Left/CollisionShape2D
onready var _right_wall_collision_shape: CollisionShape2D = $BossFight/Walls/Right/CollisionShape2D
onready var _left_trigger: Area2D = $BossFight/Triggers/Left
onready var _right_trigger: Area2D = $BossFight/Triggers/Right
onready var _left_trigger_collision_shape: CollisionShape2D = $BossFight/Triggers/Left/CollisionShape2D
onready var _right_trigger_collision_shape: CollisionShape2D = $BossFight/Triggers/Right/CollisionShape2D
onready var _lightning_floor: LightningFloor = $BossFight/LightningFloor
onready var _warden_offscreen_rumble: AudioStreamPlayer = $WardenOffscreenRumble
onready var _transition_trigger: Area2D = $TransitionTrigger
onready var _save_manager: CentralHubSaveManager = $SaveManager

var _player: Player = null

func _ready() -> void:
    _left_trigger.connect('body_entered', self, '_on_player_triggered_boss_fight')
    _right_trigger.connect('body_entered', self, '_on_player_triggered_boss_fight')

    _transition_trigger.connect(
        'body_entered', self, '_on_player_entered_transition_trigger_area')

    assert(not _pre_warden_hard_save_areas.empty())
    for hard_save_area in _pre_warden_hard_save_areas:
        assert(hard_save_area is Area2D)
        hard_save_area.connect(
            'body_entered', self, '_on_player_entered_hard_save_area', [hard_save_area])

    set_process(false)

func _process(delta: float) -> void:
    # Processing is enabled once the player triggers the boss fight, but we wait
    # until the player is grounded not near the door before actually pausing
    # player processing (in case they are airborne when they trigger the fight).
    if _player.is_on_ground() and not _player_standing_over_door():
        _player.set_process_unhandled_input(false)
        _player.set_physics_process(false)
        _player.set_direction(Util.direction(_player, _central_lock))
        _player.change_state({'new_state': Player.State.IDLE})
        set_process(false)

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

func get_door_area() -> Area2D:
    return _door_area

func get_offscreen_rumble_audio_player() -> AudioStreamPlayer:
    return _warden_offscreen_rumble

func lamp_reset() -> void:
    if _save_manager.warden_fight_state == CentralHubSaveManager.WardenFightState.POST_FIGHT:
        return

    match _save_manager.warden_fight_state:
        CentralHubSaveManager.WardenFightState.PRE_FIGHT:
            set_enable_boss_fight_triggers(false)
            set_enable_boss_fight_walls(false)

        CentralHubSaveManager.WardenFightState.FIGHT:
            set_enable_boss_fight_triggers(true)
            set_enable_boss_fight_walls(false)

            _central_lock.get_closing_door().set_opened()

    # Reset lightning floor, in case it was active at the time of death.
    _lightning_floor.stop()

    # Reset fragile platform.
    _fragile_platform.reset()

    # Reset focus point.
    _camera_focus_point.set_active(true)

func _player_standing_over_door() -> bool:
    return _door_area.get_overlapping_bodies().has(_player)

func _trigger_boss_fight() -> void:
    _save_manager.warden_fight_state = CentralHubSaveManager.WardenFightState.FIGHT
    set_enable_boss_fight_triggers(false)
    emit_signal('boss_fight_triggered')

func _on_player_entered_hard_save_area(player: Player, hard_save_area: Area2D) -> void:
    # Make sure player is facing the center of the room, so that it looks more
    # "correct" if they're respawning after dying to the warden without having
    # rested anywhere else first.
    var direction_to_save: int = Util.Direction.LEFT
    match hard_save_area:
        _hard_save_area_1, _hard_save_area_3:
            direction_to_save = Util.Direction.RIGHT

        _hard_save_area_2, _hard_save_area_4:
            direction_to_save = Util.Direction.LEFT

    # Save relevant details.
    player.save_manager.last_saved_global_position = hard_save_area.global_position
    player.save_manager.last_saved_direction_to_lamp = direction_to_save
    player.get_health_pack_manager().update_saved_num_health_packs()

    # Permanently disable all four hard save areas.
    _save_manager.player_entered_hard_save_area = true
    for area in _pre_warden_hard_save_areas:
        area.call_deferred(
            'disconnect', 'body_entered', self, '_on_player_entered_hard_save_area')
        area.get_node('CollisionShape2D').set_deferred('disabled', true)

func _on_player_triggered_boss_fight(player: Player) -> void:
    if not player:
        return

    if _save_manager.warden_fight_state == CentralHubSaveManager.WardenFightState.POST_FIGHT:
        return

    # Sometimes, the player can trigger the boss fight while in the SLEEP state
    # immediately after dying. My theory is that this is because of undefined
    # iteration order when calling lamp_reset() on all the lamp_reset group
    # nodes, which can lead to the boss fight triggers being re-enabled before
    # the player moves to the last saved position.
    if player.current_state() == Player.State.SLEEP:
        return

    _player = player
    _trigger_boss_fight()

func _on_player_entered_transition_trigger_area(player: Player) -> void:
    if not player:
        return

    emit_signal('player_entered_central_hub_shaft')
