extends KinematicBody2D

export(Util.Direction) var direction := Util.Direction.RIGHT

const SPEED := 0.25 * Util.TILE_SIZE

onready var _hurtbox: Area2D = $Hurtbox

func _ready() -> void:
    $AnimationPlayer.play('walk')
    _set_direction(direction)

func _physics_process(delta: float) -> void:
    if is_on_wall() or _is_touching_hazard():
        _set_direction(-1 * direction)

    move_and_slide(Vector2(direction * SPEED, 1), Util.FLOOR_NORMAL)

func _set_direction(new_direction: int) -> void:
    direction = new_direction
    $Sprite.flip_h = (new_direction == Util.Direction.LEFT)

func _is_touching_hazard() -> bool:
    # Since there doesn't seem to be a way for a KinematicBody2D to query the
    # Area2Ds that overlap it, we just use the hurtbox Area2D to detect
    # collisions with hazards like spikes, taking advantage of the fact that the
    # collision shapes are the same.
    for area in _hurtbox.get_overlapping_areas():
        if Util.in_collision_layer(area, 'hazards'):
            return true
    return false