extends Room

enum RoomState {
    PRE_FIGHT,
    WAVE_1,
    WAVE_2,
    WAVE_3,
    POST_FIGHT,
}

var _current_wave_enemy_count := 0

onready var _enemies_node: Node2D = $Enemies
onready var _closing_door: StaticBody2D = $ClosingDoor
onready var _door_trigger: Area2D = $ClosingDoorTrigger
onready var _save_manager: GrappleArenaSaveManager = $SaveManager

func _ready() -> void:
    _door_trigger.connect('body_entered', self, '_start_arena')

    set_process(false)

func _process(delta: float) -> void:
    match _save_manager.current_room_state:
        RoomState.PRE_FIGHT:
            # Close door.
            _closing_door.close()

            # Spawn wave 1 enemies.
            var sentry_drone_left := Preloads.SentryDrone.instance()
            var leaping_failure := Preloads.LeapingFailure.instance()
            var sentry_drone_right := Preloads.SentryDrone.instance()
            sentry_drone_right.initial_direction = Util.Direction.LEFT

            _spawn_enemy_at(sentry_drone_left, Vector2(64, 128))
            _spawn_enemy_at(leaping_failure, Vector2(96, 164))
            _spawn_enemy_at(sentry_drone_right, Vector2(256, 128))

            _save_manager.current_room_state = RoomState.WAVE_1

        RoomState.WAVE_1:
            if _current_wave_enemy_count == 0:
                # Spawn wave 2 enemies.
                var sticky_drone := Preloads.StickyDrone.instance()
                sticky_drone.floor_normal = StickyDrone.FloorNormal.RIGHT
                var ranged_sentry_drone := Preloads.RangedSentryDrone.instance()
                ranged_sentry_drone.initial_direction = Util.Direction.LEFT
                var sluggish_failure := Preloads.SluggishFailure.instance()

                _spawn_enemy_at(sticky_drone, Vector2(16, 136))
                _spawn_enemy_at(ranged_sentry_drone, Vector2(256, 112))
                _spawn_enemy_at(sluggish_failure, Vector2(160, 116))

                _connect_projectile_spawner_signals()

                _save_manager.current_room_state = RoomState.WAVE_2

        RoomState.WAVE_2:
            if _current_wave_enemy_count == 0:
                # Spawn wave 3 enemies.
                var ranged_sentry_drone_left := Preloads.RangedSentryDrone.instance()
                var ranged_sentry_drone_right := Preloads.RangedSentryDrone.instance()
                ranged_sentry_drone_right.initial_direction = Util.Direction.LEFT
                var leaping_failure := Preloads.LeapingFailure.instance()

                _spawn_enemy_at(ranged_sentry_drone_left, Vector2(80, 128))
                _spawn_enemy_at(ranged_sentry_drone_right, Vector2(240, 128))
                _spawn_enemy_at(leaping_failure, Vector2(160, 116))

                _connect_projectile_spawner_signals()

                _save_manager.current_room_state = RoomState.WAVE_3

        RoomState.WAVE_3:
            if _current_wave_enemy_count == 0:
                # Open door.
                _closing_door.open()

                _save_manager.current_room_state = RoomState.POST_FIGHT

        RoomState.POST_FIGHT:
            set_process(false)

func lamp_reset() -> void:
    set_process(false)

    _closing_door.open()

    _current_wave_enemy_count = 0

    # Despawn all enemies in case the player dies during the arena fight.
    for enemy in _enemies_node.get_children():
        enemy.queue_free()

    # Unless the player has already completed the arena, reset to PRE_FIGHT
    # state on lamp rest (e.g. if the player dies in the middle of the fight).
    if _save_manager.current_room_state != RoomState.POST_FIGHT:
        _save_manager.current_room_state = RoomState.PRE_FIGHT

func _start_arena(player: Player) -> void:
    if not player:
        return

    if _save_manager.current_room_state != RoomState.PRE_FIGHT:
        return

    set_process(true)

func _spawn_enemy_at(enemy: Node2D, spawn_point_local: Vector2) -> void:
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
