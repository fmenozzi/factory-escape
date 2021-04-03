extends Node2D
class_name LightningBolt

export(Color) var color := Color('#ff4f78')
export(float) var length_tiles := 4.0
export(float) var width := 1.0
export(int) var num_segments := 8
export(float) var max_y_perturb := 4.0

onready var _line: Line2D = $Line2D
onready var _timer: Timer = $Timer

var _points := []
var _starting_sign: float

func _ready() -> void:
    randomize()
    _starting_sign = sign(rand_range(-1.0, 1.0))

    _line.width = width
    _line.default_color = color

    _timer.connect('timeout', self, '_on_timeout')
    _timer.start(rand_range(0.01, 0.05))

func _update_points() -> void:
    var length := length_tiles * Util.TILE_SIZE
    var segment_length := length / float(num_segments)

    var sgn := _starting_sign

    _points= [Vector2.ZERO]

    for i in range(1, num_segments):
        # Initial segment, distributed uniformly on x-axis.
        var point := Vector2(length * (i / float(num_segments)), 0.0)

        # Perturb along x-axis, making sure not to overlap with neighboring
        # points.
        var x_perturb := rand_range(-0.4 * segment_length, 0.4 * segment_length)

        # Perturb along y-axis, making sure to alternate sign each iteration.
        var y_perturb := rand_range(0.0, max_y_perturb) * sgn
        sgn *= -1

        _points.append(point + Vector2(x_perturb, y_perturb))

    _points.append(Vector2(length, 0.0))

func _on_timeout() -> void:
    if not _points.empty():
        _points.pop_front()
    else:
        _update_points()

    _line.points = _points

    _timer.start(0.05 + rand_range(-0.01, 0.01))
