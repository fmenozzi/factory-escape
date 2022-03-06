extends RoomFe

enum RoomState {
    PRE_FIGHT,
    DRONE_FIGHT,
}
var _current_room_state: int = RoomState.PRE_FIGHT

onready var _enemy_spawn_trigger_area: Area2D = $ClosingDoorManager/ClosingDoorTrigger
onready var _arena_camera_pos: Position2D = $CameraAnchors/Right
onready var _closing_door: StaticBody2D = $ClosingDoorManager/ClosingDoor
onready var _enemies_node: Node2D = $Enemies
onready var _player_camera: Camera2D = null

func _ready() -> void:
    _enemy_spawn_trigger_area.connect(
        'body_entered', self, '_on_player_triggered_enemy_spawns')

func _spawn_enemy_at(enemy: KinematicBody2D, spawn_point: Vector2) -> void:
    enemy.set_position(spawn_point)
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

    _enemies_node.add_child(enemy)
    alpha_tween.start()

func _on_player_triggered_enemy_spawns(player: Player) -> void:
    if not player:
        return

    _player_camera = player.get_camera()

    if _current_room_state == RoomState.PRE_FIGHT:
        _current_room_state = RoomState.DRONE_FIGHT

        _closing_door.close()
        _player_camera.detach_and_move_to_global(_arena_camera_pos.position)

        # Spawn drones.
        _spawn_enemy_at(Preloads.SentryDrone.instance(), Vector2(240, 96))
        _spawn_enemy_at(Preloads.SentryDrone.instance(), Vector2(320, 64))
        _spawn_enemy_at(Preloads.SentryDrone.instance(), Vector2(400, 96))

func _on_enemy_death(enemy: KinematicBody2D) -> void:
    if _enemies_node.get_child_count() > 1:
        return

    if _current_room_state == RoomState.DRONE_FIGHT:
        _closing_door.open()
        _player_camera.reattach()
