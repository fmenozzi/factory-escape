extends 'res://actors/enemies/state.gd'

var _player: Player
var _shot_finished: bool

func enter(spider_drone: SpiderDrone, previous_state_dict: Dictionary) -> void:
    _player = Util.get_player()
    _shot_finished = false

    # Pause current animation.
    spider_drone.get_animation_player().stop(false)

    # Shoot laser at player's current location.
    var laser := spider_drone.get_laser()
    laser.connect('shot_finished', self, '_on_shot_finished')
    laser.shoot(laser.to_local(_player.get_center()))

func exit(spider_drone: SpiderDrone) -> void:
    pass

func update(spider_drone: SpiderDrone, delta: float) -> Dictionary:
    if _shot_finished:
        return {'new_state': SpiderDrone.State.IDLE}

    return {'new_state': SpiderDrone.State.NO_CHANGE}

func _on_shot_finished() -> void:
    _shot_finished = true
