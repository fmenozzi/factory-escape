extends "res://game/game_interface.gd"

onready var _cargo_lift: Room = $World/Rooms/CargoLift

func _ready() -> void:
    _cargo_lift.connect('player_entered_cargo_lift', self, '_on_player_entered_cargo_lift')

func _on_player_entered_cargo_lift() -> void:
    print('player entered cargo lift')
