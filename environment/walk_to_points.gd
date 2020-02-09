extends Node2D

onready var _left: Position2D = $Left
onready var _right: Position2D = $Right
onready var _player: Player = Util.get_player()

func get_closest_point() -> Position2D:
    var player_pos := _player.global_position

    var distance_to_left := player_pos.distance_to(_left.global_position)
    var distance_to_right := player_pos.distance_to(_right.global_position)

    return _left if distance_to_left <= distance_to_right else _right
