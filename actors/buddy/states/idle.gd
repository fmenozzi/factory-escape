extends 'res://actors/buddy/states/state.gd'

func enter(buddy: Buddy, previous_state_dict: Dictionary) -> void:
    buddy.get_animation_player().play('idle')

    var dialog_area := buddy.get_dialog_area()
    dialog_area.connect('body_entered', self, '_on_player_entered', [buddy])
    dialog_area.connect('body_exited', self, '_on_player_exited', [buddy])

func exit(buddy: Buddy) -> void:
    var dialog_area := buddy.get_dialog_area()
    dialog_area.disconnect('body_entered', self, '_on_player_entered')
    dialog_area.disconnect('body_exited', self, '_on_player_exited')

func update(buddy: Buddy, delta: float) -> Dictionary:
    return {'new_state': Buddy.State.NO_CHANGE}

func _on_player_entered(player: Player, buddy: Buddy) -> void:
    if not player:
        return

    buddy.get_fade_in_out_label().fade_in()

func _on_player_exited(player: Player, buddy: Buddy) -> void:
    if not player:
        return

    buddy.get_fade_in_out_label().fade_out()
