extends 'res://actors/enemies/state.gd'

func enter(sticky_drone: StickyDrone, previous_state_dict: Dictionary) -> void:
    # The crouch animation itself will include a function call that transitions
    # the sticky drone to the SHOOT state halfway through the animation. This
    # allows for the laser shot to appear during the crouch animation.
    sticky_drone.get_animation_player().play('crouch')

func exit(sticky_drone: StickyDrone) -> void:
    pass

func update(sticky_drone: StickyDrone, delta: float) -> Dictionary:
    return {'new_state': StickyDrone.State.NO_CHANGE}
