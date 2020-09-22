extends Room

enum RoomState {
    PRE_FIGHT,
    WAVE_1,
    WAVE_2,
    WAVE_3,
    POST_FIGHT,
}
var _current_room_state: int = RoomState.PRE_FIGHT

var _current_wave_enemy_count := 0

var _door_triggered := false

onready var _enemies_node: Node2D = $Enemies
onready var _door_trigger: Area2D = $ClosingDoorSystem/DoorTrigger
onready var _entrance: StaticBody2D = $ClosingDoorSystem/Entrance
onready var _exit: StaticBody2D = $ClosingDoorSystem/Exit

func _ready() -> void:
    _door_trigger.connect('body_entered', self, '_start_arena')

    # For drone paths.
    randomize()

func _process(delta: float) -> void:
    match _current_room_state:
        RoomState.PRE_FIGHT:
            if _door_triggered and not _entrance.is_closed() and not _exit.is_closed():
                _entrance.close()
                _exit.close()

                # Spawn wave 1 enemies.
                _spawn_enemy_at(Preloads.SluggishFailure.instance(), Vector2(448, 80))
                _spawn_enemy_at(Preloads.SluggishFailure.instance(), Vector2(576, 80))
                _spawn_enemy_at(Preloads.WorkerDrone.instance(), Vector2(516, 96))

                _current_room_state = RoomState.WAVE_1

        RoomState.WAVE_1:
            if _current_wave_enemy_count == 0:
                # Spawn wave 2 enemies.
                _spawn_enemy_at(Preloads.LeapingFailure.instance(), Vector2(448, 96))
                _spawn_enemy_at(Preloads.LeapingFailure.instance(), Vector2(576, 96))

                _current_room_state = RoomState.WAVE_2

        RoomState.WAVE_2:
            if _current_wave_enemy_count == 0:
                # Spawn wave 3 enemies.
                _spawn_enemy_at(Preloads.SentryDrone.instance(), Vector2(448, 80))
                _spawn_enemy_at(Preloads.SentryDrone.instance(), Vector2(576, 80))
                _spawn_enemy_at(Preloads.RangedSentryDrone.instance(), Vector2(516, 96))

                _connect_projectile_spawner_signals()

                _current_room_state = RoomState.WAVE_3

        RoomState.WAVE_3:
            if _current_wave_enemy_count == 0:
                # Open the doors.
                _entrance.open()
                _exit.open()

                _current_room_state = RoomState.POST_FIGHT

        RoomState.POST_FIGHT:
            set_process(false)

func _start_arena(player: Player) -> void:
    if not player:
        return

    if _current_room_state != RoomState.PRE_FIGHT:
        return

    _door_triggered = true

func _spawn_enemy_at(enemy: KinematicBody2D, spawn_point_global: Vector2) -> void:
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
    enemy.global_position = spawn_point_global
    alpha_tween.start()

func _on_enemy_death(enemy: KinematicBody2D) -> void:
    _current_wave_enemy_count -= 1
