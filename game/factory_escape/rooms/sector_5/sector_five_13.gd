extends Room

func _ready() -> void:
    $EscapeSequenceTrigger.connect('body_entered', self, '_start_escape_sequence')

func _start_escape_sequence(player: Player) -> void:
    if not player:
        return

    EscapeSequenceEffects.start()
