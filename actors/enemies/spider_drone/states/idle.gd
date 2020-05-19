extends 'res://actors/enemies/state.gd'

func enter(spider_drone: SpiderDrone, previous_state_dict: Dictionary) -> void:
    spider_drone.get_animation_player().play('idle')

func exit(spider_drone: SpiderDrone) -> void:
    pass

func update(spider_drone: SpiderDrone, delta: float) -> Dictionary:
    return {'new_state': SpiderDrone.State.NO_CHANGE}
