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

            _camera.detach_and_move_to_global(Vector2(320, 88))

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
    _room.add_child(slime)
    _slimes.append(slime)

func _on_slime_death(slime: Slime) -> void:
    if not slime:
        return

    _slimes.erase(slime)
    if _slimes.empty():
        _current_room_state = RoomState.POST_FIGHT
        _camera.reattach()
        _closing_door.open()