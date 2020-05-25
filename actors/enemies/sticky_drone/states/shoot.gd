extends 'res://actors/enemies/state.gd'

var _player: Player
var _shot_finished: bool

func enter(sticky_drone: StickyDrone, previous_state_dict: Dictionary) -> void:
    _player = Util.get_player()
    _shot_finished = false

    sticky_drone.get_animation_player().play('crouching')

    # Shoot laser at player's current location.
    var laser := sticky_drone.get_laser()
    laser.connect('shot_finished', self, '_on_shot_finished')
    laser.shoot(laser.to_local(_player.get_center()))

func exit(sticky_drone: StickyDrone) -> void:
    pass

func update(sticky_drone: StickyDrone, delta: float) -> Dictionary:
    if _shot_finished:
        return {'new_state': StickyDrone.State.UNCROUCH}

    return {'new_state': StickyDrone.State.NO_CHANGE}

func _on_shot_finished() -> void:
    _shot_finished = true
