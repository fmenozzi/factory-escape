extends KinematicBody2D
class_name StickyDrone

enum State {
    NO_CHANGE,
    IDLE,
    WALK,
    ALERTED,
    UNALERTED,
    CROUCH,
    SHOOT,
    UNCROUCH,
    DIE,
}

export(Util.Direction) var direction := Util.Direction.RIGHT
export(State) var initial_state := State.IDLE

enum FloorNormal {
    UP,
    DOWN,
    LEFT,
    RIGHT,
}
export(FloorNormal) var floor_normal := FloorNormal.UP

onready var STATES := {
    State.IDLE:      $States/Idle,
    State.WALK:      $States/Walk,
    State.ALERTED:   $States/Alerted,
    State.UNALERTED: $States/Unalerted,
    State.CROUCH:    $States/Crouch,
    State.SHOOT:     $States/Shoot,
    State.UNCROUCH:  $States/Uncrouch,
    State.DIE:       $States/Die,
}

var _current_state: Node = null
var _current_state_enum: int = -1

onready var _health: Health = $Health
onready var _flash_manager: Node = $FlashManager
onready var _physics_manager: PhysicsManager = $PhysicsManager
onready var _aggro_manager: AggroManager = $AggroManager
onready var _react_sprite: ReactSprite = $ReactSprite
onready var _sprite: Sprite = $Sprite
onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _hitbox_collision_shape: CollisionShape2D = $Hitbox/CollisionShape2D
onready var _hurtbox_collision_shape: CollisionShape2D = $Hurtbox/CollisionShape2D
onready var _laser: Laser = $Laser

func _ready() -> void:
    _health.connect('health_changed', self, '_on_health_changed')
    _health.connect('died', self, '_on_died')

    set_direction(direction)

    _react_sprite.change_state(ReactSprite.State.NONE)

    # Set rotation to match the specified floor normal. This floor normal will
    # also be used as a basis for movement. Also ensure that the react sprite's
    # orientation is the same regardless of the floor normal by undoing its
    # rotation.
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
    _change_state({'new_state': _current_state_enum})

func _physics_process(delta: float) -> void:
    var new_state_dict = _current_state.update(self, delta)
    if new_state_dict['new_state'] != State.NO_CHANGE:
        _change_state(new_state_dict)

func move(
    velocity: Vector2,
    snap: Vector2 = Util.NO_SNAP,
    floor_normal: Vector2 = Util.FLOOR_NORMAL
) -> void:
    # Adjust velocity by factoring in the current rotation (which will have been
    # set according the the floor_normal property).
    velocity = velocity.rotated(deg2rad(self.rotation_degrees))

    .move_and_slide_with_snap(velocity, snap, floor_normal)

func set_direction(new_direction: int) -> void:
    direction = new_direction
    _sprite.flip_h = (new_direction == Util.Direction.LEFT)

func take_hit(damage: int, player: Player) -> void:
    _health.take_damage(damage)
    _flash_manager.start_flashing()

func get_floor_normal() -> Vector2:
    match floor_normal:
        FloorNormal.UP:
            return Vector2.UP
        FloorNormal.DOWN:
            return Vector2.DOWN
        FloorNormal.LEFT:
            return Vector2.LEFT
        FloorNormal.RIGHT:
            return Vector2.RIGHT

    # Shouldn't get here.
    return Vector2.ZERO

func get_physics_manager() -> PhysicsManager:
    return _physics_manager

func get_aggro_manager() -> AggroManager:
    return _aggro_manager

func get_react_sprite() -> ReactSprite:
    return _react_sprite

func get_animation_player() -> AnimationPlayer:
    return _animation_player

func get_laser() -> Laser:
    return _laser

func set_hit_and_hurt_boxes_disabled(disabled: bool) -> void:
    _hitbox_collision_shape.set_deferred('disabled', disabled)
    _hurtbox_collision_shape.set_deferred('disabled', disabled)

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

# This function is called during the 'crouch' animation in order to transition
# to the SHOOT state in the middle of the animation. This effectively means that
# the drone will start shooting in the middle of this animation, and this
# animation is allowed to finish before starting the looped 'crouching'
# animation from within the SHOOT state.
func _transition_to_shoot_state(pause_before_shooting: bool = false) -> void:
    _change_state({
        'new_state': State.SHOOT,
        'pause_before_shooting': pause_before_shooting,
    })

func _on_health_changed(old_health: int, new_health: int) -> void:
    print('STICKY DRONE HIT (new health: ', new_health, ')')

# TODO: Make death nicer (animation, effects, etc.).
func _on_died() -> void:
    _change_state({'new_state': State.DIE})
