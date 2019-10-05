extends KinematicBody2D

export(Util.Direction) var direction := Util.Direction.RIGHT

const SPEED := 0.25 * Util.TILE_SIZE

func _ready() -> void:
    $AnimationPlayer.play('walk')
    _set_direction(direction)

func _physics_process(delta: float) -> void:
    if is_on_wall():
        _set_direction(-1 * direction)

    move_and_slide(Vector2(direction * SPEED, 1), Util.FLOOR_NORMAL)

func _set_direction(new_direction: int) -> void:
    direction = new_direction
    $Sprite.flip_h = (new_direction == Util.Direction.LEFT)