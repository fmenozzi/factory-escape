extends Room

enum RoomState {
    PRE_FIGHT,
    WAVE_1,
    WAVE_2,
    WAVE_3,
    POST_FIGHT,
}

var _current_wave_enemy_count := 0
var _player_camera: Camera2D = null

onready var _enemies_node: Node2D = $Enemies
onready var _closing_door_left: StaticBody2D = $ClosingDoorLeft
onready var _closing_door_right: StaticBody2D = $ClosingDoorRight
onready var _arena_camera_anchor: Position2D = $ArenaCameraAnchor
onready var _door_trigger: Area2D = $ClosingDoorTrigger
onready var _save_manager: MaintenanceArenaSaveManager = $SaveManager

func _ready() -> void:
    _save_manager.current_room_state = RoomState.PRE_FIGHT

    _door_trigger.connect('body_entered', self, '_start_arena')

    set_process(false)

func _process(delta: float) -> void:
    match _save_manager.current_room_state:
        RoomState.PRE_FIGHT:
            # Pin the camera to the center of the room.
            _player_camera.detach_and_move_to_global(
                self.to_global(_arena_camera_anchor.position))

            # Close both doors.
            _closing_door_left.close()
            _closing_door_right.close()

            # Spawn wave 1 enemies.
            var sluggish_failure_left := Preloads.SluggishFailure.instance()
            var sluggish_failure_right := Preloads.SluggishFailure.instance()
            sluggish_failure_right.initial_direction = Util.Direction.LEFT
            _spawn_enemy_at(sluggish_failure_left, Vector2(256, 168))
            _spawn_enemy_at(sluggish_failure_right, Vector2(384, 168))

            _save_manager.current_room_state = RoomState.WAVE_1

        RoomState.WAVE_1:
            if _current_wave_enemy_count == 0:
                # Spawn wave 2 enemies.
                var leaping_failure_left := Preloads.LeapingFailure.instance()
                var leaping_failure_right := Preloads.LeapingFailure.instance()
                leaping_failure_right.initial_direction = Util.Direction.LEFT
                _spawn_enemy_at(leaping_failure_left, Vector2(208, 168))
                _spawn_enemy_at(leaping_failure_right, Vector2(432, 168))

                _save_manager.current_room_state = RoomState.WAVE_2

        RoomState.WAVE_2:
            if _current_wave_enemy_count == 0:
                # Spawn wave 3 enemies.
                _spawn_enemy_at(Preloads.SluggishFailure.instance(), Vector2(320, 104))
                _spawn_enemy_at(Preloads.SentryDrone.instance(), Vector2(232, 152))
                _spawn_enemy_at(Preloads.SentryDrone.instance(), Vector2(408, 72))

                _save_manager.current_room_state = RoomState.WAVE_3

        RoomState.WAVE_3:
            if _current_wave_enemy_count == 0:
                # Re-attach camera to player.
                _player_camera.reattach()

                # Open both doors.
                _closing_door_left.open()
                _closing_door_right.open()

                _save_manager.current_room_state = RoomState.POST_FIGHT

        RoomState.POST_FIGHT:
            set_process(false)

func lamp_reset() -> void:
    set_process(false)

    _closing_door_left.open()
    _closing_door_right.open()

    _current_wave_enemy_count = 0

    # Despawn all enemies in case the player dies during the arena fight.
    for enemy in _enemies_node.get_children():
        enemy.queue_free()

    # Unless the player has already completed the arena, reset to PRE_FIGHT
    # state on lamp rest (e.g. if the player dies in the middle of the fight).
    if _save_manager.current_room_state != RoomState.POST_FIGHT:
        _save_manager.current_room_state = RoomState.PRE_FIGHT

        # In case the player died while the camera was detached in the middle
        # of the arena fight, reattach the camera without tweening it (i.e. set
        # the camera's position to (0, 0) immediately). If the player dies
        # before reaching the arena, the player camera will be null.
        if _player_camera != null:
            _player_camera.reattach(false)

func _start_arena(player: Player) -> void:
    if not player:
        return

    if _save_manager.current_room_state != RoomState.PRE_FIGHT:
        return

    _player_camera = player.get_camera()
    assert(_player_camera != null)

    set_process(true)

func _spawn_enemy_at(enemy: KinematicBody2D, spawn_point_local: Vector2) -> void:
    enemy.get_node('Health').connect('died', self, '_on_enemy_death', [enemy])

    # Tween transparency so that enemies fade in as they spawn.
    var prop := 'modulate'
    var old := Color(1, 1, 1, 0) # Transparent
    var new := Color(1, 1, 1, 1) # Opaque
    var duration := 0.5
    var trans := Tween.TRANS_LINEAR
    var easing := Tween.EASE_IN

    var alpha_tween := Tween.new()
    alpha_tween.interpolate_property(
        enemy, prop, old, new, duration, trans, easing)
    enemy.add_child(alpha_tween)

    _current_wave_enemy_count += 1

    _enemies_node.add_child(enemy)
    enemy.position = spawn_point_local
    alpha_tween.start()

func _on_enemy_death(enemy: KinematicBody2D) -> void:
    _current_wave_enemy_count -= 1
