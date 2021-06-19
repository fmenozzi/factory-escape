extends 'res://actors/player/states/player_state.gd'

onready var _flash_manager: Node = $FlashManager

var _player: Player = null

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    _player = player

    player.get_animation_player().play('heal')

    player.get_health_pack_manager().consume_health_pack()

func exit(player: Player) -> void:
    _flash_manager.stop_flashing()

    # If the heal animation did not complete (due to being hit), the heal fails,
    # so emit the corresponding signal.
    if player.get_animation_player().is_playing():
        player.emit_signal('player_heal_failed')

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    if not player.get_animation_player().is_playing():
        # Emit the player_heal_succeeded signal here, instead of in exit(). This
        # means that the heal will not take effect if the player is hit by an
        # enemy during the animation, and the health pack will be consumed
        # anyway.
        player.emit_signal('player_heal_succeeded')

        if player.is_in_air():
            return {'new_state': Player.State.FALL}
        else:
            return {'new_state': Player.State.IDLE}

    if player.is_on_ground():
        player.move(Vector2(0, player.get_slight_downward_move()))

    return {'new_state': Player.State.NO_CHANGE}

func _play_heal_started_sound() -> void:
    _player.get_sound_manager().play(PlayerSoundManager.Sounds.HEAL_STARTED)
