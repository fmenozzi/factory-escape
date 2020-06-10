extends Node2D
class_name Turret

export(Util.Direction) var direction := Util.Direction.RIGHT

enum FloorNormal {
    UP,
    DOWN,
    LEFT,
    RIGHT,
}
export(FloorNormal) var floor_normal := FloorNormal.UP

enum State {
    NO_CHANGE,
    ROTATE,
    PAUSE,
}

onready var STATES := {
    State.ROTATE: $States/Rotate,
    State.PAUSE:  $States/Pause,
}

var _current_state: Node = null
var _current_state_enum: int = -1

var _rotation_direction := -1

onready var _health: Health = $Health
onready var _body_flash_manager: Node = $Body/FlashManager
onready var _head: Node2D = $Head
onready var _projectile_spawner: ProjectileSpawner = $Head/ProjectileSpawner
onready var _head_sprite: Sprite = $Head/Sprite
onready var _head_flash_manager: Node = $Head/FlashManager

func _ready() -> void:
    _health.connect('health_changed', self, '_on_health_changed')
    _health.connect('died', self, '_on_died')

    set_direction(direction)

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

    _current_state_enum = State.ROTATE
    _current_state = STATES[_current_state_enum]
    _change_state({
        'new_state': _current_state_enum,
        'rotation_direction': _rotation_direction
    })

func _physics_process(delta: float) -> void:
    var new_state_dict = _current_state.update(self, delta)
    if new_state_dict['new_state'] != State.NO_CHANGE:
        _change_state(new_state_dict)

func set_direction(new_direction: int) -> void:
    direction = new_direction
    _head.scale.x = new_direction

func take_hit(damage: int, player: Player) -> void:
    _health.take_damage(damage)
    _body_flash_manager.start_flashing()
    _head_flash_manager.start_flashing()

func rotate_head(angle: float) -> void:
    _head.rotation = fposmod(_head.rotation + angle, 2*PI)
    _head_sprite.flip_v = (PI/2 <= _head.rotation and _head.rotation < 3*PI/2)

func shoot() -> void:
    # The initial direction is simply the turret head's current rotation.
    var shoot_direction := Vector2.RIGHT.rotated(_head.rotation)

    # Because the entire turret can itself be rotated according to the floor
    # normal, make sure to correct the direction by factoring in the overall
    # rotation.
    shoot_direction = shoot_direction.rotated(deg2rad(self.rotation_degrees))

    # Factor in the direction of the head sprite as well.
    shoot_direction *= self.direction

    _projectile_spawner.shoot_energy_projectile(shoot_direction)

func get_rotation_direction() -> int:
    return _rotation_direction

func change_rotation_direction() -> void:
    _rotation_direction *= -1

func _change_state(new_state_dict: Dictionary) -> void:
    var old_state_enum := _current_state_enum
    var new_state_enum: int = new_state_dict['new_state']

    # Before passing along the new_state_dict to the new state (since we want
    # any additional metadata keys passed too), rename the 'new_state' key to
    # 'previous_state'.
    new_state_dict.erase('new_state')
    new_state_dict['previous_state'] = old_state_enum

    _current_state.exit(self)
    _current_state_enum = new_state_enum
    _current_state = STATES[new_state_enum]
    _current_state.enter(self, new_state_dict)

func _on_health_changed(old_health: int, new_health: int) -> void:
    print('TURRET HIT (new health: ', new_health, ')')

# TODO: Make death nicer (animation, effects, etc.).
func _on_died() -> void:
    print('TURRET DIED')
    queue_free()
