extends Node2D
class_name LightningBolt

export(float) var length_tiles := 4.0
export(float) var width := 1.0
export(int) var num_segments := 8

onready var _line: Line2D = $Line2D

func _ready() -> void:
    randomize()

    _line.width = width

    _update_points()

func _update_points() -> void:
    var points := [Vector2.ZERO]
    var length := length_tiles * Util.TILE_SIZE
    var segment_length := length / float(num_segments)

    for i in range(1, num_segments):
        # Initial segment, distributed uniformly on x-axis.
        var point := Vector2(length * (i / float(num_segments)), 0.0)

        # Perturb along x-axis, making sure not to overlap with neighboring
        # points.
        var x_perturb := rand_range(-0.3 * segment_length, 0.3 * segment_length)

        # Perturb along y-axis, making sure to alternate sign each iteration.
        var y_perturb := 4.0 * _alternate_sign(i)

        points.append(point + Vector2(x_perturb, y_perturb))

    points.append(Vector2(length, 0.0))

    _line.points = points

func _alternate_sign(i: int) -> float:
    return 1.0 if (i % 2 == 0) else -1.0
