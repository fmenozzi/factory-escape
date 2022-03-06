extends RoomFe

enum RoomState {
    PRE_FIGHT,
    FIGHT,
    POST_FIGHT,
}
var _current_room_state: int = RoomState.PRE_FIGHT

onready var _closing_door: StaticBody2D = $ClosingDoorManager/ClosingDoor
onready var _closing_door_trigger: Area2D = $ClosingDoorManager/ClosingDoorTrigger
onready var _enemies_node: Node2D = $Enemies

var _sluggish_failures := []
var _player_camera: Camera2D

func _ready() -> void:
    _closing_door_trigger.connect('body_entered', self, '_on_player_entered')

func _on_player_entered(player: Player) -> void:
    if not player:
        return

    _player_camera = player.get_camera()

    match _current_room_state:
        RoomState.PRE_FIGHT:
            _current_room_state = RoomState.FIGHT

            _closing_door.close()

            _player_camera.detach_and_move_to_global(Vector2(320, 90))

            _spawn_failure_at(Vector2(320, 32))
            _spawn_failure_at(Vector2(248, 64))
            _spawn_failure_at(Vector2(392, 64))

        RoomState.FIGHT:
            pass
        RoomState.POST_FIGHT:
            pass


func _spawn_failure_at(position: Vector2) -> void:
    var failure := Preloads.SluggishFailure.instance()
    failure.set_position(position)
    failure.get_node('Health').connect(
        'died', self, '_on_failure_death', [failure])

    # Tween transparency so that failures fade in as they spawn.
    var prop := 'modulate'
    var old := Color(1, 1, 1, 0) # Transparent
    var new := Color(1, 1, 1, 1) # Opaque
    var duration := 0.5
    var trans := Tween.TRANS_LINEAR
    var easing := Tween.EASE_IN

    var alpha_tween := Tween.new()
    alpha_tween.interpolate_property(
        failure, prop, old, new, duration, trans, easing)
    failure.add_child(alpha_tween)

    _enemies_node.add_child(failure)
    alpha_tween.start()
    _sluggish_failures.append(failure)

func _on_failure_death(failure: SluggishFailure) -> void:
    if not failure:
        return

    _sluggish_failures.erase(failure)
    if _sluggish_failures.empty():
        _current_room_state = RoomState.POST_FIGHT
        _player_camera.reattach()
        _closing_door.open()
