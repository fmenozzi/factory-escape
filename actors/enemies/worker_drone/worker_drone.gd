extends KinematicBody2D
class_name WorkerDrone

export(Util.Direction) var direction := Util.Direction.RIGHT

enum State {
    NO_CHANGE,
    WANDER,
    STAGGER,
    DIE,
}

export(State) var initial_state := State.WANDER

onready var STATES := {
    State.WANDER:  $States/Wander,
    State.STAGGER: $States/Stagger,
    State.DIE:     $States/Die,
}

var _current_state: Node = null
var _current_state_enum: int = -1

onready var _health: Health = $Health
onready var _flash_manager: Node = $FlashManager
onready var _physics_manager: PhysicsManager = $PhysicsManager
onready var _pushback_manager: PushbackManager = $PushbackManager
onready var _sprite: Sprite = $Sprite
onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _hitbox_collision_shape: CollisionShape2D = $Hitbox/CollisionShape2D
onready var _hurtbox_collision_shape: CollisionShape2D = $Hurtbox/CollisionShape2D
onready var _obstacle_detector: RayCast2D = $ObstacleDetector

func _ready() -> void:
    _animation_player.play('idle')

    set_direction(direction)

    _health.connect('health_changed', self, '_on_health_changed')

    _current_state_enum = initial_state
    _current_state = STATES[_current_state_enum]
    _change_state({'new_state': _current_state_enum})

func _physics_process(delta: float) -> void:
    var new_state_dict = _current_state.update(self, delta)
    if new_state_dict['new_state'] != State.NO_CHANGE:
        _change_state(new_state_dict)

func set_direction(new_direction: int) -> void:
    direction = new_direction
    _sprite.flip_h = (new_direction == Util.Direction.LEFT)

func take_hit(damage: int, player: Player) -> void:
    _health.take_damage(damage)
    _flash_manager.start_flashing()
    if _health.get_current_health() == 0:
        # TODO: Make death nicer (animation, effects, etc.).
        _change_state({'new_state': State.DIE})
    else:
        var direction := player.global_position.direction_to(global_position)
        _change_state({
            'new_state': State.STAGGER,
            'direction_from_hit': direction,
        })

func get_physics_manager() -> PhysicsManager:
    return _physics_manager

func get_pushback_manager() -> PushbackManager:
    return _pushback_manager

func move(velocity: Vector2, snap: Vector2 = Util.NO_SNAP) -> void:
    .move_and_slide_with_snap(velocity, snap, Util.FLOOR_NORMAL)

func is_hitting_obstacle() -> bool:
    return .is_on_floor() or .is_on_ceiling() or .is_on_wall()

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

func _on_health_changed(old_health: int, new_health: int) -> void:
    print('WORKER DRONE HIT (new health: ', new_health, ')')
