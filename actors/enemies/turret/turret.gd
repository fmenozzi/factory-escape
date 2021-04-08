extends Node2D
class_name Turret

enum FloorNormal {
    UP,
    DOWN,
    LEFT,
    RIGHT,
}

enum State {
    NO_CHANGE,
    ROTATE,
    WAIT,
    ALERTED,
    SHOOT,
    PAUSE,
    DIE,
}

export(Util.Direction) var initial_direction := Util.Direction.RIGHT
export(State) var initial_state := State.ROTATE
export(FloorNormal) var floor_normal := FloorNormal.UP

onready var STATES := {
    State.ROTATE:  $States/Rotate,
    State.WAIT:    $States/Wait,
    State.ALERTED: $States/Alerted,
    State.SHOOT:   $States/Shoot,
    State.PAUSE:   $States/Pause,
    State.DIE:     $States/Die,
}

var direction: int

var _current_state: Node = null
var _current_state_enum: int = -1

var _rotation_direction := 0

onready var _health: Health = $Health
onready var _aggro_manager: AggroManager = $AggroManager
onready var _sound_manager: EnemySoundManager = $EnemySoundManager
onready var _react_sprite: ReactSprite = $ReactSprite
onready var _body_flash_manager: Node = $Body/FlashManager
onready var _head: Node2D = $Head
onready var _projectile_spawner: ProjectileSpawner = $Head/ProjectileSpawner
onready var _head_sprite: Sprite = $Head/Sprite
onready var _head_flash_manager: Node = $Head/FlashManager
onready var _scanner: Scanner = $Head/Scanner
onready var _hitbox_collision_shape: CollisionShape2D = $Hitbox/CollisionShape2D
onready var _hurtbox_collision_shape: CollisionShape2D = $Hurtbox/CollisionShape2D
onready var _animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
    _health.connect('died', self, '_on_died')

    set_direction(initial_direction)

    _rotation_direction = -initial_direction

    _react_sprite.change_state(ReactSprite.State.NONE)

    # Set rotation to match the specified floor normal. This floor normal will
    # also be used to orient the turret so that the body sprite is against the
    # wall. Also ensure that the react sprite's orientation is the same
    # regardless of the floor normal by undoing its rotation.
    match floor_normal:
        FloorNormal.UP:
            self.rotation_degrees = 0
            _react_sprite.rotation_degrees = 0
        FloorNormal.DOWN:
            self.rotation_degrees = 180
            _react_sprite.rotation_degrees = -180
        FloorNormal.LEFT:
            self.rotation_degrees = -90
            _react_sprite.rotation_degrees = 90
        FloorNormal.RIGHT:
            self.rotation_degrees = 90
            _react_sprite.rotation_degrees = -90

    _current_state_enum = initial_state
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
    _head.rotation = new_direction * PI/2
    _head.scale.x = new_direction

func take_hit(damage: int, player: Player) -> void:
    _health.take_damage(damage)
    _body_flash_manager.start_flashing()
    _head_flash_manager.start_flashing()
    _sound_manager.play(EnemySoundManager.Sounds.ENEMY_HIT_MECHANICAL)

func rotate_head_to(new_rotation: float) -> void:
    _head.rotation = new_rotation
    _head_sprite.flip_h = (_head.scale.x * _head.rotation) < 0

func shoot() -> void:
    # The initial direction is simply the turret head's current rotation.
    var shoot_direction := Vector2.UP.rotated(_head.rotation)

    # Because the entire turret can itself be rotated according to the floor
    # normal, make sure to correct the direction by factoring in the overall
    # rotation.
    shoot_direction = shoot_direction.rotated(deg2rad(self.rotation_degrees))

    # Factor in the direction of the head sprite as well.
    shoot_direction *= self.direction

    _projectile_spawner.shoot_energy_projectile(shoot_direction)

func get_aggro_manager() -> AggroManager:
    return _aggro_manager

func get_react_sprite() -> ReactSprite:
    return _react_sprite

func get_scanner() -> Scanner:
    return _scanner

func get_head_rotation() -> float:
    return _head.rotation

func get_rotation_direction() -> int:
    return _rotation_direction

func get_animation_player() -> AnimationPlayer:
    return _animation_player

func get_projectile_spawner() -> Position2D:
    return _projectile_spawner

func set_hit_and_hurt_boxes_disabled(disabled: bool) -> void:
    _hitbox_collision_shape.set_deferred('disabled', disabled)
    _hurtbox_collision_shape.set_deferred('disabled', disabled)

func change_rotation_direction() -> void:
    _rotation_direction *= -1

func pause() -> void:
    if _current_state_enum != State.DIE:
        _change_state({'new_state': State.PAUSE})

    set_physics_process(false)
    _scanner.set_enabled(false)
    _animation_player.stop(false)

func resume() -> void:
    if _current_state_enum != State.DIE:
        _change_state({
            'new_state': initial_state,
            'rotation_direction': _rotation_direction,
        })

    set_physics_process(true)
    _scanner.set_enabled(true)

func room_reset() -> void:
    if _current_state_enum != State.DIE:
        lamp_reset()

func lamp_reset() -> void:
    set_direction(initial_direction)
    _health.heal_to_full()
    _change_state({
        'new_state': initial_state,
        'rotation_direction': _rotation_direction,
    })

func is_dead() -> bool:
    return _current_state_enum == State.DIE

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

# TODO: Make death nicer (animation, effects, etc.).
func _on_died() -> void:
    _change_state({'new_state': State.DIE})
