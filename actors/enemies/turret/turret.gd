extends Node2D
class_name Turret

enum FloorNormal {
    UP,
    DOWN,
    LEFT,
    RIGHT,
}
export(FloorNormal) var floor_normal := FloorNormal.UP

onready var _head: Node2D = $Head
onready var _head_sprite: Sprite = $Head/Sprite
onready var _projectile_spawner: ProjectileSpawner = $Head/ProjectileSpawner

func _ready() -> void:
    # Set rotation to match the specified floor normal. This floor normal will
    # also be used to orient the turret so that the body sprite is against the
    # wall.
    match floor_normal:
        FloorNormal.UP:
            self.rotation_degrees = 0
        FloorNormal.DOWN:
            self.rotation_degrees = 180
        FloorNormal.LEFT:
            self.rotation_degrees = -90
        FloorNormal.RIGHT:
            self.rotation_degrees = 90

func rotate_head(angle: float) -> void:
    _head.rotation = fposmod(_head.rotation + angle, 2*PI)
    _head_sprite.flip_v = (PI/2 <= _head.rotation and _head.rotation < 3*PI/2)

func shoot() -> void:
    # The initial direction is simply the turret head's current rotation.
    var direction := Vector2.RIGHT.rotated(_head.rotation)

    # Because the entire turret can itself be rotated according to the floor
    # normal, make sure to correct the direction by factoring in the overall
    # rotation.
    var direction_corrected := direction.rotated(deg2rad(self.rotation_degrees))

    _projectile_spawner.shoot_energy_projectile(direction_corrected)
