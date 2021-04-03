extends Node2D
class_name LightningWall

onready var _base_emitter: Node2D = $BaseEmitter
onready var _movable_emitter: Node2D = $MovableEmitter

func _ready() -> void:
    assert(_base_emitter.position == Vector2.ZERO)

    var bolt_length := _movable_emitter.position.length()
    var bolt_angle := _movable_emitter.position.angle()

    _base_emitter.rotation = _movable_emitter.position.angle()
    _movable_emitter.rotation = _movable_emitter.position.rotated(PI).angle()

    for bolt in _base_emitter.get_children():
        bolt.length = bolt_length
    for bolt in _movable_emitter.get_children():
        bolt.length = bolt_length

func pause() -> void:
    pass

func resume() -> void:
    pass
