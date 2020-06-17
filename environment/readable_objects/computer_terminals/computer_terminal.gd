extends ReadableObject

func _ready() -> void:
    ._ready()
    $AnimationPlayer.play('idle')
