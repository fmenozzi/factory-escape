extends 'res://actors/player/states/player_state.gd'

onready var _attack_combo_timer: Timer = $AttackComboTimer

func _ready() -> void:
    _attack_combo_timer.one_shot = true
    _attack_combo_timer.wait_time = 0.5

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    if _attack_combo_timer.is_stopped():
        _attack_combo_timer.start()
        player.start_attack('attack_1')
    else:
        _attack_combo_timer.stop()
        player.start_attack('attack_2')

func exit(player: Player) -> void:
    player.stop_attack()

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    if not player.get_animation_player().is_playing():
        return {'new_state': Player.State.IDLE}

    # Apply slight downward movement. This is important mostly for ensuring that
    # we're snapped to the ground, so that the ground doesn't disappear out from
    # under us during the attack, such as if we're on a downward-moving platform.
    player.move(Vector2(0, 10))

    return {'new_state': Player.State.NO_CHANGE}
