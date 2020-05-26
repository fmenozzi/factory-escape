extends KinematicBody2D
class_name StickyDrone

enum State {
    NO_CHANGE,
    IDLE,
    WALK,
    CROUCH,
    SHOOT,
    UNCROUCH,
}

export(Util.Direction) var direction := Util.Direction.RIGHT

enum FloorNormal {
    UP,
    DOWN,
    LEFT,
    RIGHT,
}
export(FloorNormal) var floor_normal := FloorNormal.UP

onready var STATES := {
    State.IDLE:     $States/Idle,
    State.WALK:     $States/Walk,
    State.CROUCH:   $States/Crouch,
    State.SHOOT:    $States/Shoot,
    State.UNCROUCH: $States/Uncrouch,
}

var _current_state: Node = null
var _current_state_enum: int = -1

onready var _health: Health = $Health
onready var _flash_manager: Node = $FlashManager
onready var _physics_manager: PhysicsManager = $PhysicsManager
onready var _sprite: Sprite = $Sprite
onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _laser: Laser = $Laser

func _ready() -> void:
    _health.connect('health_changed', self, '_on_health_changed')
    _health.connect('died', self, '_on_died')

    set_direction(direction)

    # Set rotation to match the specified floor normal. This floor normal will
    # also be used as a basis for movement.
    match floor_normal:
        FloorNormal.UP:
            self.rotation_degrees = 0
        FloorNormal.DOWN:
            self.rotation_degrees = 180
        FloorNormal.LEFT:
            self.rotation_degrees = -90
        FloorNormal.RIGHT:
            self.rotation_degrees = 90

    _current_state_enum = State.CROUCH
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

func get_animation_player() -> AnimationPlayer:
    return _animation_player

func get_laser() -> Laser:
    return _laser

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
    print('STICKY DRONE HIT (new health: ', new_health, ')')

# TODO: Make death nicer (animation, effects, etc.).
func _on_died() -> void:
    print('STICKY DRONE DIED')
    queue_free()
