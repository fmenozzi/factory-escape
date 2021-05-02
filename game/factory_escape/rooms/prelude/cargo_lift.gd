extends Room

signal player_entered_cargo_lift

func _ready() -> void:
    $TransitionTrigger.connect('body_entered', self, '_on_player_entered_trigger_area')

func _on_player_entered_trigger_area(player: Player) -> void:
    if not player:
        return

    emit_signal('player_entered_cargo_lift')
