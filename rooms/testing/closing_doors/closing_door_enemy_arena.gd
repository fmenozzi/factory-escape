extends Node2D

const Slime := preload('res://actors/enemies/slime/Slime.tscn')

enum RoomState {
    PRE_FIGHT,
    FIGHT,
    POST_FIGHT,
}
var _current_room_state: int = RoomState.PRE_FIGHT

onready var _closing_door: StaticBody2D = $ClosingDoor
onready var _closing_door_trigger: Area2D = $ClosingDoorTrigger
onready var _room: Room = get_parent()
onready var _camera: Camera2D = Util.get_player().get_camera()

var _slimes := []

func _ready() -> void:
    _closing_door_trigger.connect('body_entered', self, '_on_player_entered')

func _on_player_entered(player: Player) -> void:
    if not player:
        return

    match _current_room_state:
        RoomState.PRE_FIGHT:
            _current_room_state = RoomState.FIGHT

            _closing_door.close()

            _camera.detach_and_move_to_global(Vector2(320, 90))

            _spawn_slime_at(Vector2(320, 32))
            _spawn_slime_at(Vector2(248, 64))
            _spawn_slime_at(Vector2(392, 64))

        RoomState.FIGHT:
            pass
        RoomState.POST_FIGHT:
            pass


func _spawn_slime_at(position: Vector2) -> void:
    var slime := Slime.instance()
    slime.set_position(position)
    slime.get_node('Health').connect('died', self, '_on_slime_death', [slime])

    # Tween transparency so that slimes fade in as they spawn.
    var prop := 'modulate'
    var old := Color(1, 1, 1, 0) # Transparent
    var new := Color(1, 1, 1, 1) # Opaque
    var duration := 0.5
    var trans := Tween.TRANS_LINEAR
    var easing := Tween.EASE_IN

    var alpha_tween := Tween.new()
    alpha_tween.interpolate_property(
        slime, prop, old, new, duration, trans, easing)
    slime.add_child(alpha_tween)

    _room.add_child(slime)
    alpha_tween.start()
    _slimes.append(slime)

func _on_slime_death(slime: Slime) -> void:
    if not slime:
        return

    _slimes.erase(slime)
    if _slimes.empty():
        _current_room_state = RoomState.POST_FIGHT
        _camera.reattach()
        _closing_door.open()
