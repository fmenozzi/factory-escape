extends ReadableObject

func _ready() -> void:
    ._ready()
    $AnimationPlayer.play('idle')
    for idx in range(0, $VisibilityBasedAudioGroup/AudioPlayers.get_child_count()):
        $VisibilityBasedAudioGroup.get_player_by_index(idx).play()
