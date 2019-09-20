extends Node2D

signal room_changed(old_room, new_room)

onready var _player: Player = $Player
onready var _camera: Camera2D = _player.get_camera()
onready var _rooms: Array = $Rooms.get_children()

# TODO: See if we can find a more efficient way of doing this that doesn't
#       involve iterating over every room in every frame. Maybe some kind of
#       map or otherwise more advanced data structure?
#
#       e.g. maybe you can use thin, one-way collision boxes at each room
#       entrance to signal room changes.
func _process(delta: float) -> void:
    for room in _rooms:
        # Transition to room once we enter a new one.
        if room != _player.curr_room and _player_in_room(_player, room):
            _player.prev_room = _player.curr_room
            _player.curr_room = room

            # Pause processing on the old room, transition to the new one, and
            # then begin processing on the new room once the transition is
            # complete.
            _player.prev_room.pause()
            _camera.transition(_player.prev_room, _player.curr_room)
            yield(_camera, 'transition_completed')
            _player.curr_room.resume()

            emit_signal('room_changed', _player.prev_room, _player.curr_room)

func _player_in_room(player: Player, room: Room) -> bool:
    var bounds := Rect2(room.get_global_position(), room.get_room_dimensions())

    return bounds.has_point(player.get_global_position())