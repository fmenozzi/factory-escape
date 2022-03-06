extends KinematicBody2D
class_name SluggishFailure

enum State {
    NO_CHANGE,
    EXPAND,
    CONTRACT,
    WAIT,
    STAGGER,
    FALL,
    RETURN_TO_LEDGE,
    PAUSE,
    DIE,
    SPAWN,
}

export(Util.Direction) var initial_direction := Util.Direction.RIGHT
export(State) var initial_state := State.CONTRACT

onready var STATES := {
    State.EXPAND:          $States/Expand,
    State.CONTRACT:        $States/Contract,
    State.WAIT:            $States/Wait,
    State.STAGGER:         $States/Stagger,
    State.FALL:            $States/Fall,
    State.RETURN_TO_LEDGE: $States/ReturnToLedge,
    State.PAUSE:           $States/Pause,
    State.DIE:             $States/Die,
    State.SPAWN:           $States/Spawn,
}

# The speed multiplier to apply once the failure becomes frightened (i.e. after
# being hit).
const FRIGHTENED_SPEED_MULTIPLIER: float = 3.0

var direction: int
var speed_multiplier := 1.0

var _initial_global_position: Vector2

var _current_state: Node = null
var _current_state_enum: int = -1

var _direction_from_hit: int = Util.Direction.NONE

onready var _flash_manager: Node = $FlashManager
onready var _physics_manager: GroundedPhysicsManager = $PhysicsManager
onready var _pushback_manager: PushbackManager = $PushbackManager
onready var _sound_manager: SluggishFailureSoundManager = $SluggishFailureSoundManager
onready var _animation_player: AnimationPlayer = $AnimationPlayer

onready var _health: Health = $Health
onready var _hurtbox: Area2D = $Hurtbox
onready var _sprite: Sprite = $Sprite

onready var _hitbox_collision_shape: CollisionShape2D = $Hitbox/CollisionShape2D
onready var _hurtbox_collision_shape: CollisionShape2D = $Hurtbox/CollisionShape2D

onready var _edge_raycast_left: RayCast2D = $LedgeDetectorRaycasts/Left
onready var _edge_raycast_right: RayCast2D = $LedgeDetectorRaycasts/Right

func _ready() -> void:
    set_direction(initial_direction)

    _initial_global_position = global_position

    _current_state_enum = initial_state
    _current_state = STATES[_current_state_enum]
    _change_state({'new_state': _current_state_enum})

    _hurtbox.connect('area_entered', self, '_on_hazard_hit')
    _hurtbox.connect('body_entered', self, '_on_hazard_hit')

    STATES[State.EXPAND].connect(
        'expanded', _sound_manager, 'play', [SluggishFailureSoundManager.Sounds.EXPAND])
    STATES[State.CONTRACT].connect(
        'contracted', _sound_manager, 'play', [SluggishFailureSoundManager.Sounds.CONTRACT])

func _physics_process(delta: float) -> void:
    var new_state_dict = _current_state.update(self, delta)
    if new_state_dict['new_state'] != State.NO_CHANGE:
        _change_state(new_state_dict)

func get_physics_manager() -> GroundedPhysicsManager:
    return _physics_manager

func get_pushback_manager() -> PushbackManager:
    return _pushback_manager

func get_sound_manager() -> SluggishFailureSoundManager:
    return _sound_manager

func get_animation_player() -> AnimationPlayer:
    return _animation_player

func get_spawn_shader_sprite() -> Sprite:
    return _sprite

func spawn() -> void:
    _change_state({'new_state': State.SPAWN})

func take_hit(damage: int, player: Player) -> void:
    _health.take_damage(damage)
    _flash_manager.start_flashing()
    _sound_manager.play(SluggishFailureSoundManager.Sounds.HIT)
    if _health.get_current_health() == 0:
        _die()
    else:
        # Once hit, the failure will attempt to flee the player by quickly
        # moving away from them.
        speed_multiplier = FRIGHTENED_SPEED_MULTIPLIER
        set_direction(Util.direction(player, self))
        _change_state({
            'new_state': State.STAGGER,
            'direction_from_hit': Util.direction(player, self),
        })

func move(velocity: Vector2, snap: Vector2 = Util.SNAP) -> void:
    .move_and_slide_with_snap(velocity, snap, Util.FLOOR_NORMAL)

func set_direction(new_direction: int) -> void:
    direction = new_direction
    _sprite.flip_h = (new_direction == Util.Direction.LEFT)

func is_off_ledge() -> bool:
    var off_left := not _edge_raycast_left.is_colliding()
    var off_right := not _edge_raycast_right.is_colliding()

    return (off_left and not off_right) or (off_right and not off_left)

func emit_dust_puff() -> void:
    Effects.spawn_dust_puff_at(global_position)

func set_hit_and_hurt_boxes_disabled(disabled: bool) -> void:
    _hitbox_collision_shape.set_deferred('disabled', disabled)
    _hurtbox_collision_shape.set_deferred('disabled', disabled)

func pause() -> void:
    if _current_state_enum != State.DIE:
        _change_state({'new_state': State.PAUSE})

    set_physics_process(false)
    _animation_player.stop(false)
    _sound_manager.set_all_muted(true)

func resume() -> void:
    if _current_state_enum != State.DIE:
        _change_state({'new_state': initial_state})

    set_physics_process(true)
    _animation_player.play()
    _sound_manager.set_all_muted(false)

    for audio_group in _sound_manager.get_all_audio_groups():
        audio_group.set_state()

func show_visuals() -> void:
    pass

func hide_visuals() -> void:
    pass

func room_reset() -> void:
    if _current_state_enum != State.DIE:
        lamp_reset()

func lamp_reset() -> void:
    global_position = _initial_global_position
    set_direction(initial_direction)
    _health.heal_to_full()
    speed_multiplier = 1.0
    _change_state({'new_state': initial_state})

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

func _die() -> void:
    _sound_manager.play(SluggishFailureSoundManager.Sounds.KILLED)

    _change_state({'new_state': State.DIE})

# Sluggish failures insta-die when touching hazards.
func _on_hazard_hit(area_or_body) -> void:
    if not area_or_body or not Collision.in_layer(area_or_body, 'hazards'):
        return

    Rumble.start(Rumble.Type.WEAK, 0.10)
    Screenshake.start(
        Screenshake.Duration.VERY_SHORT, Screenshake.Amplitude.VERY_SMALL)

    var enemy_hit_effect: EnemyHitEffect
    if Util.get_player().curr_room.get_section() == RoomFe.Section.SECTOR_5:
        enemy_hit_effect = Preloads.EnemyHitEffectSectorFive.instance()
    else:
        enemy_hit_effect = Preloads.EnemyHitEffect.instance()
    var world := get_parent().get_parent().get_parent().get_parent().get_parent()
    world.get_node('TemporaryNodes').add_child(enemy_hit_effect)
    enemy_hit_effect.global_position = global_position

    _die()
