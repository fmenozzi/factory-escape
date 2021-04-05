extends Node2D
class_name ReadableObject

export(Array, String) var dialog

onready var _readable_area: Area2D = $ReadableArea
onready var _fade_in_out_label: Label = $FadeInOutLabel
onready var _reading_points: Node2D = $WalkToPoints

func _ready() -> void:
    set_readable(true)

func _on_player_entered(player: Player) -> void:
    if not player:
        return

    player.set_nearby_readable_object(self)

    label_fade_in()

func _on_player_exited(player: Player) -> void:
    if not player:
        return

    player.set_nearby_readable_object(null)

    label_fade_out()

func get_closest_reading_point() -> Position2D:
    return _reading_points.get_closest_point()

func set_readable(readable: bool) -> void:
    if readable:
        _readable_area.connect('body_entered', self, '_on_player_entered')
        _readable_area.connect('body_exited', self, '_on_player_exited')
    else:
        _readable_area.disconnect('body_entered', self, '_on_player_entered')
        _readable_area.disconnect('body_exited', self, '_on_player_exited')

func label_fade_in() -> void:
    _fade_in_out_label.fade_in()

func label_fade_out() -> void:
    _fade_in_out_label.fade_out()
