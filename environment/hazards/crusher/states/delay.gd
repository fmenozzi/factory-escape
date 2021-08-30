extends 'res://actors/enemies/enemy_state.gd'

onready var _delay_timer: Timer = $Delay

var _animation_name := ''

func _ready() -> void:
    _delay_timer.one_shot = true

func enter(crusher: Crusher, previous_state_dict: Dictionary) -> void:
    assert('animation' in previous_state_dict)
    _animation_name = previous_state_dict['animation']

    assert('delay' in previous_state_dict)
    _delay_timer.wait_time = previous_state_dict['delay']
    _delay_timer.start()

func exit(crusher: Crusher) -> void:
    pass

func update(crusher: Crusher, delta: float) -> Dictionary:
    if _delay_timer.is_stopped():
        return {
            'new_state': Crusher.State.CRUSH_LOOP,
            'animation': _animation_name,
        }

    return {'new_state': Crusher.State.NO_CHANGE}
