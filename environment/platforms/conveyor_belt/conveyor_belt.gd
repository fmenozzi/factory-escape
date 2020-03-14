extends StaticBody2D

const SPEED: float = 3.0 * Util.TILE_SIZE

export(Util.Direction) var direction := Util.Direction.RIGHT

onready var _animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
    assert(direction != Util.Direction.NONE)

    # Play appropriate animation and set constant linear velocity depending on
    # conveyor belt direction. Note that the 'move' animation is for moving to
    # the right.
    match direction:
        Util.Direction.LEFT:
            _animation_player.play_backwards('move')
            set_constant_linear_velocity(Vector2(-SPEED, 0.0))

        Util.Direction.RIGHT:
            _animation_player.play('move')
            set_constant_linear_velocity(Vector2(SPEED, 0.0))
