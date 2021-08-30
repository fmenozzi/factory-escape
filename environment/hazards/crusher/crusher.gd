extends Node2D
class_name Crusher

enum Speed {
    SLOW,
    FAST,
}

export(float) var initial_delay := 0.0
export(Speed) var speed := Speed.SLOW

enum State {
    NO_CHANGE,
    DELAY,
    CRUSH_LOOP,
}
var _current_state: Node = null
var _current_state_enum: int = -1

onready var STATES := {
    State.DELAY:      $States/Delay,
    State.CRUSH_LOOP: $States/CrushLoop,
}

onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _dust_puff_spawn_positions: Array = $CrusherHead/DustPuffSpawnPositions.get_children()
onready var _visibility_notifier: VisibilityNotifier2D = $VisibilityNotifier2D
onready var _windup_sound_slow: VisibilityBasedAudioPlayer = $VisibilityBasedAudioGroup/AudioPlayers/Windup
onready var _windup_sound_fast: VisibilityBasedAudioPlayer = $VisibilityBasedAudioGroup/AudioPlayers/WindupFast
onready var _impact_sound: VisibilityBasedAudioPlayer = $VisibilityBasedAudioGroup/AudioPlayers/Impact

var _initial_state_dict := {}

func _ready() -> void:
    var initial_state_dict := initial_state()
    _current_state_enum = initial_state_dict['new_state']
    _current_state = STATES[_current_state_enum]

func _physics_process(delta: float) -> void:
    var new_state_dict = _current_state.update(self, delta)
    if new_state_dict['new_state'] != State.NO_CHANGE:
        _change_state(new_state_dict)

func get_animation_player() -> AnimationPlayer:
    return _animation_player

func pause() -> void:
    _animation_player.stop()
    set_physics_process(false)

func resume() -> void:
    _change_state(initial_state())

    set_physics_process(true)

func show_visuals() -> void:
    pass

func hide_visuals() -> void:
    # Reset animation after transitioning away from the parent room, since this
    # will also reset the crusher head position.
    _animation_player.seek(0, true)

func initial_state() -> Dictionary:
    var animation_name = ''
    match speed:
        Speed.SLOW:
            animation_name = 'crush_loop_slow'
        Speed.FAST:
            animation_name = 'crush_loop_fast'

    var initial_state_dict := {
        'new_state': State.CRUSH_LOOP,
        'animation': animation_name,
    }
    if initial_delay > 0:
        initial_state_dict['new_state'] = State.DELAY
        initial_state_dict['delay'] = initial_delay

    return initial_state_dict

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

func _windup_slow() -> void:
    _windup_sound_slow.play()

func _windup_fast() -> void:
    _windup_sound_fast.play()

func _impact() -> void:
    if _player_is_near():
        Screenshake.start(Screenshake.Duration.SHORT, Screenshake.Amplitude.SMALL)

    _impact_sound.play()

    for dust_puff_spawn_position in _dust_puff_spawn_positions:
        Effects.spawn_dust_puff_at(self.to_global(dust_puff_spawn_position.position))

func _player_is_near() -> bool:
    return _visibility_notifier.is_on_screen()
