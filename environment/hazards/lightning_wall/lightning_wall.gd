extends Node2D
class_name LightningWall

export(float) var hitbox_width := 4.0

onready var _base_emitter: Node2D = $BaseEmitter
onready var _movable_emitter: Node2D = $MovableEmitter
onready var _hitbox_collision_shape: CollisionShape2D = $Hitbox/CollisionShape2D

func _ready() -> void:
    assert(_base_emitter.position == Vector2.ZERO)

    var bolt_length := _movable_emitter.position.length()
    var bolt_angle := _movable_emitter.position.angle()

    _base_emitter.rotation = _movable_emitter.position.angle()
    _movable_emitter.rotation = _movable_emitter.position.rotated(PI).angle()

    _hitbox_collision_shape.shape = RectangleShape2D.new()
    _hitbox_collision_shape.shape.extents = Vector2(bolt_length / 2.0, hitbox_width / 2.0)
    _hitbox_collision_shape.rotation = _movable_emitter.position.angle()
    _hitbox_collision_shape.position = _movable_emitter.position / 2.0

    for bolt in _base_emitter.get_children():
        bolt.length = bolt_length
    for bolt in _movable_emitter.get_children():
        bolt.length = bolt_length

func pause() -> void:
    pass

func resume() -> void:
    pass
