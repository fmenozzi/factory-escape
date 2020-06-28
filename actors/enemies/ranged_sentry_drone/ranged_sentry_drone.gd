extends KinematicBody2D
class_name RangedSentryDrone

enum State {
    NO_CHANGE,
    IDLE,
    FLY_TO_POINT,
    ALERTED,
    UNALERTED,
    FOLLOW_PLAYER,
    SHOOT,
    DIE,
}

export(Util.Direction) var direction := Util.Direction.RIGHT

onready var STATES := {
    State.IDLE:          $States/Idle,
    State.FLY_TO_POINT:  $States/FlyToPoint,
    State.ALERTED:       $States/Alerted,
    State.UNALERTED:     $States/Unalerted,
    State.FOLLOW_PLAYER: $States/FollowPlayer,
    State.SHOOT:         $States/Shoot,
    State.DIE:           $States/Die,
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
onready var _projectile_spawner: Position2D = $ProjectileSpawner

func _ready() -> void:
    _health.connect('health_changed', self, '_on_health_changed')
    _health.connect('died', self, '_on_died')

    set_direction(direction)

    _react_sprite.change_state(ReactSprite.State.NONE)

    _current_state_enum = State.IDLE
    _current_state = STATES[_current_state_enum]
    _change_state({'new_state': _current_state_enum})

func _physics_process(delta: float) -> void:
    var new_state_dict = _current_state.update(self, delta)
    if new_state_dict['new_state'] != State.NO_CHANGE:
        _change_state(new_state_dict)

func move(velocity: Vector2, snap: Vector2 = Util.NO_SNAP) -> void:
    .move_and_slide_with_snap(velocity, snap, Util.FLOOR_NORMAL)

func set_direction(new_direction: int) -> void:
    direction = new_direction
    _sprite.flip_h = (new_direction == Util.Direction.LEFT)

func take_hit(damage: int, player: Player) -> void:
    _health.take_damage(damage)
    _flash_manager.start_flashing()

func get_physics_manager() -> PhysicsManager:
    return _physics_manager

func get_aggro_manager() -> AggroManager:
    return _aggro_manager

func get_react_sprite() -> ReactSprite:
    return _react_sprite

func get_animation_player() -> AnimationPlayer:
    return _animation_player

func get_projectile_spawner() -> Position2D:
    return _projectile_spawner

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
    print('RANGED SENTRY DRONE HIT (new health: ', new_health, ')')

# TODO: Make death nicer (animation, effects, etc.).
func _on_died() -> void:
    _change_state({'new_state': State.DIE})
