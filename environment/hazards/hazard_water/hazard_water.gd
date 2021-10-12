extends Area2D
class_name HazardWater

const PARTICLES_PER_PIXEL := 0.75

onready var _collision_shape: CollisionShape2D = $CollisionShape2D
onready var _body_sprite: Sprite = $BodySprite
onready var _surface_foam: TextureRect = $SurfaceFoam
onready var _bubbles: Particles2D = $Bubbles
onready var _audio_group: VisibilityBasedAudioGroup = $VisibilityBasedAudioGroup

func _ready() -> void:
    assert(_collision_shape.shape is RectangleShape2D)

    var half_size: Vector2 = _collision_shape.shape.extents
    var size: Vector2 = 2 * half_size

    # The type of texture isn't super important, as the shader will be used to
    # create the gradient, so just pick one that's easy to resize. Also make
    # sure to center water body sprite over collision shape.
    _body_sprite.set_material(_body_sprite.get_material().duplicate(true))
    _body_sprite.texture = ImageTexture.new()
    _body_sprite.texture.size = size
    _body_sprite.position = _collision_shape.position

    # Resize the surface foam margins to match the width of the collision shape,
    # making sure that the foam is only on the top to prevent tiling vertically.
    _surface_foam.margin_left = _collision_shape.position.x - half_size.x
    _surface_foam.margin_right = _collision_shape.position.x + half_size.x
    _surface_foam.margin_top = _collision_shape.position.y - half_size.y - 8
    _surface_foam.margin_bottom = _collision_shape.position.y - half_size.y + 8

    # Match the position and emission box width to the collision shape, and set
    # the number of particles emitted based on the particle density.
    _bubbles.set_process_material(_bubbles.get_process_material().duplicate(true))
    _bubbles.position = _collision_shape.position + Vector2(0, -half_size.y + 8)
    _bubbles.process_material.emission_box_extents.x = half_size.x - 2
    _bubbles.amount = PARTICLES_PER_PIXEL * size.x

    # Play bubbling sound and center audio player on water.
    _audio_group.position = _collision_shape.position
    _audio_group.get_player_by_name('Bubbling').play()

func pause() -> void:
    _audio_group.get_player_by_name('Bubbling').stop()

func resume() -> void:
    _audio_group.get_player_by_name('Bubbling').play()

func show_visuals() -> void:
    pass

func hide_visuals() -> void:
    pass
