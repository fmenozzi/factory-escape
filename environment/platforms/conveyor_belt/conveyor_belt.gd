extends StaticBody2D

const SPEED: float = 3.0 * Util.TILE_SIZE

export(Util.Direction) var direction := Util.Direction.RIGHT

onready var _sprite: Sprite = $Sprite
onready var _animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
    assert(direction != Util.Direction.NONE)

    # Set constant linear velocity and flip sprite according to direction. Note
    # that the 'move' animation is for moving to the right.
    _animation_player.play('move')
    _sprite.flip_h = (direction == Util.Direction.LEFT)
    set_constant_linear_velocity(Vector2(direction * SPEED, 0.0))
