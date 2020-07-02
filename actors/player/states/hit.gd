extends 'res://actors/player/states/player_state.gd'

onready var _invincibility_flash_manager: Node = $FlashManager

var _hit_effect_finished := false

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    player.get_animation_player().play('stagger')

    _hit_effect_finished = false

    Rumble.start(Rumble.Type.STRONG, 0.15, Rumble.Priority.HIGH)
    Screenshake.start(
        Screenshake.Duration.LONG,
        Screenshake.Amplitude.SMALL,
        Screenshake.Priority.HIGH)

    player.get_health().set_status(Health.Status.INVINCIBLE)
    _invincibility_flash_manager.connect(
        'flashing_finished', self, '_on_invincibility_flashing_finished', [player])
    _invincibility_flash_manager.start_flashing()


    var player_hit_effect := player.get_hit_effect()
    player_hit_effect.connect('hit_effect_finished', self, '_on_hit_effect_finished')
    player_hit_effect.play_hit_effect()

func exit(player: Player) -> void:
    pass

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    if _hit_effect_finished:
        return {'new_state': Player.State.NEXT_STATE_IN_SEQUENCE}

    return {'new_state': Player.State.NO_CHANGE}

func _on_hit_effect_finished() -> void:
    _hit_effect_finished = true

func _on_invincibility_flashing_finished(player: Player) -> void:
    player.get_health().set_status(Health.Status.NONE)
