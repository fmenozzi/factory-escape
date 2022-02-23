extends 'res://actors/player/states/player_state.gd'

export(float) var duration := 2.0

onready var _timer: Timer = $Duration

func _ready() -> void:
    _timer.one_shot = true
    _timer.wait_time = duration

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    player.get_animation_player().play('idle')

    _timer.start()

func exit(player: Player) -> void:
    pass

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    if _timer.is_stopped():
        return {'new_state': Player.State.NEXT_STATE_IN_SEQUENCE}

    return {'new_state': Player.State.NO_CHANGE}
