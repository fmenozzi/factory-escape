extends 'res://actors/player/states/player_state.gd'

onready var _invincibility_flash_manager: Node = $FlashManager

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    player.get_animation_player().play('hazard_hit')
    player.get_sound_manager().play(PlayerSoundManager.Sounds.HAZARD_HIT)

    Rumble.start(Rumble.Type.STRONG, 0.25, Rumble.Priority.HIGH)
    Screenshake.start(
        Screenshake.Duration.MEDIUM,
        Screenshake.Amplitude.SMALL,
        Screenshake.Priority.HIGH)

    player.get_hit_effect().play_hit_effect()

    player.get_health().set_status(Health.Status.INVINCIBLE)
    _invincibility_flash_manager.connect(
        'flashing_finished', self, '_on_invincibility_flashing_finished', [player])
    _invincibility_flash_manager.start_flashing()

func exit(player: Player) -> void:
    pass

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    return {'new_state': Player.State.NO_CHANGE}

func _on_invincibility_flashing_finished(player: Player) -> void:
    player.get_health().set_status(Health.Status.NONE)
