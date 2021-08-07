extends Area2D
class_name HazardWater

onready var _collision_shape: CollisionShape2D = $CollisionShape2D
onready var _body_sprite: Sprite = $BodySprite

func _ready() -> void:
    assert(_collision_shape.shape is RectangleShape2D)

    var half_size: Vector2 = _collision_shape.shape.extents
    var size: Vector2 = 2 * half_size

    # The type of texture isn't super important, as the shader will be used to
    # create the gradient, so just pick one that's easy to resize. Also make
    # sure to center water body sprite over collision shape
    _body_sprite.texture = ImageTexture.new()
    _body_sprite.texture.size = size
    _body_sprite.position = _collision_shape.position

func pause() -> void:
    pass

func resume() -> void:
    pass
