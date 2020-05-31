extends 'res://actors/enemies/state.gd'

var _player: Player
var _shot_finished: bool

func enter(sticky_drone: StickyDrone, previous_state_dict: Dictionary) -> void:
    _player = Util.get_player()
    _shot_finished = false

    sticky_drone.get_animation_player().queue('crouching')

    var laser := sticky_drone.get_laser()

    # If the previous state was the shoot state, include a pause whose length is
    # equal to the duration of the laser's telegraph.
    assert('pause_before_shooting' in previous_state_dict)
    if previous_state_dict['pause_before_shooting']:
        yield(get_tree().create_timer(laser.TELEGRAPH_DURATION), 'timeout')

    # Shoot laser at player's current location.
    laser.connect('shot_finished', self, '_on_shot_finished')
    laser.shoot(laser.to_local(_player.get_center()))

func exit(sticky_drone: StickyDrone) -> void:
    pass

func update(sticky_drone: StickyDrone, delta: float) -> Dictionary:
    var aggro_manager := sticky_drone.get_aggro_manager()

    if _shot_finished:
        # Once aggroed, sticky drone will only unaggro when out of range, and
        # NOT when player is no longer in line of sight (i.e. the drone will
        # "track" the player through cover).
        if aggro_manager.in_aggro_range():
            return {
                'new_state': StickyDrone.State.SHOOT,
                'pause_before_shooting': true
            }

        return {'new_state': StickyDrone.State.UNCROUCH}

    return {'new_state': StickyDrone.State.NO_CHANGE}

func _on_shot_finished() -> void:
    _shot_finished = true