extends 'res://actors/player/states/player_state.gd'

var _hit_effect_finished := false

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    player.get_animation_player().play('stagger')

    _hit_effect_finished = false

    var player_hit_effect := player.get_hit_effect()
    player_hit_effect.connect('hit_effect_finished', self, '_on_hit_effect_finished')
    player_hit_effect.play_hit_effect()

func exit(player: Player) -> void:
    pass

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    if _hit_effect_finished:
        return {'new_state': Player.State.IDLE}

    return {'new_state': Player.State.NO_CHANGE}

func _on_hit_effect_finished() -> void:
    _hit_effect_finished = true
