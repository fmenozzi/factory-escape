extends Node2D
class_name LightningWall

export(float) var hitbox_width := 4.0

onready var _base_emitter: Node2D = $BaseEmitter
onready var _base_emitter_bolts: Node2D = $BaseEmitter/Bolts
onready var _base_emitter_sparks: Particles2D = $BaseEmitter/Sparks
onready var _movable_emitter: Node2D = $MovableEmitter
onready var _movable_emitter_bolts: Node2D = $MovableEmitter/Bolts
onready var _movable_emitter_sparks: Particles2D = $MovableEmitter/Sparks
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

    # Make sure to account for the offset of the Bolts subchild in each emitter.
    for bolt in _base_emitter_bolts.get_children():
        bolt.length = bolt_length - (2 * _base_emitter_bolts.position.length())
    for bolt in _movable_emitter_bolts.get_children():
        bolt.length = bolt_length- (2 * _movable_emitter_bolts.position.length())

func pause() -> void:
    _base_emitter_sparks.emitting = false
    _movable_emitter_sparks.emitting = false

    for bolt in _base_emitter_bolts.get_children():
        bolt.pause()
    for bolt in _movable_emitter_bolts.get_children():
        bolt.pause()

func resume() -> void:
    _base_emitter_sparks.emitting = true
    _movable_emitter_sparks.emitting = true

    for bolt in _base_emitter_bolts.get_children():
        bolt.resume()
    for bolt in _movable_emitter_bolts.get_children():
        bolt.resume()
