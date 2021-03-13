extends Node2D
class_name AudioStreamPlayerVisibility

enum State {
    VISIBLE,
    ATTENUATING,
    INVISIBLE,
}

export(float, -80.0, 24.0) var max_volume_db := 0.0

export(float, 0.0, 32.0) var object_visibility_radius_tiles := 0.5
export(float, 0.0, 32.0) var attenuation_visibility_radius_tiles := 1.0

onready var _audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
onready var _object_visibility: VisibilityNotifier2D = $ObjectVisibility
onready var _attenuation_visibility: VisibilityNotifier2D = $AttenuationVisibility
onready var _tween: Tween = $VolumeTween

var _state: int

func _ready() -> void:
    # Set starting volume.
    _audio_stream_player.volume_db = max_volume_db

    # Create visibility rects from radii.
    assert(object_visibility_radius_tiles > 0)
    assert(attenuation_visibility_radius_tiles > 0)
    assert(object_visibility_radius_tiles < attenuation_visibility_radius_tiles)
    var obj_radius := object_visibility_radius_tiles * Util.TILE_SIZE
    var att_radius := attenuation_visibility_radius_tiles * Util.TILE_SIZE
    _object_visibility.rect = Rect2(
        -obj_radius, -obj_radius, 2 * obj_radius, 2 * obj_radius)
    _attenuation_visibility.rect = Rect2(
        -att_radius, -att_radius, 2 * att_radius, 2 * att_radius)

    # Connect VisibilityNotifier2D signals to enable state transitions. Tween to
    # new volumes in these state transitions.
    _object_visibility.connect(
        'screen_entered', self, '_set_state', [State.VISIBLE, true])
    _object_visibility.connect(
        'screen_exited', self, '_set_state', [State.ATTENUATING, true])
    _attenuation_visibility.connect(
        'screen_entered', self, '_set_state', [State.ATTENUATING, true])
    _attenuation_visibility.connect(
        'screen_exited', self, '_set_state', [State.INVISIBLE, true])

    # Set initial volume immediately here (i.e. don't tween to new volume).
    set_state(false)

func get_player() -> AudioStreamPlayer:
    return _audio_stream_player

func set_state(tween_to_new_volume: bool) -> void:
    if _object_visibility.is_on_screen():
        _set_state(State.VISIBLE, tween_to_new_volume)
    elif _attenuation_visibility.is_on_screen():
        _set_state(State.ATTENUATING, tween_to_new_volume)
    else:
        _set_state(State.INVISIBLE, tween_to_new_volume)

func _set_state(new_state: int, tween_to_new_volume: bool) -> void:
    assert(new_state in [State.VISIBLE, State.ATTENUATING, State.INVISIBLE])

    match new_state:
        State.VISIBLE:
            _set_volume(max_volume_db, tween_to_new_volume)

        State.ATTENUATING:
            # Subtracting 10 dB is roughly halving perceived loudness.
            _set_volume(max_volume_db - 10.0, tween_to_new_volume)

        State.INVISIBLE:
            _set_volume(-80.0, tween_to_new_volume)

    _state = new_state

func _set_volume(new_volume_db: float, tween_to_new_volume: bool) -> void:
    if tween_to_new_volume:
        _tween.remove_all()
        _tween.interpolate_property(_audio_stream_player, 'volume_db',
            _audio_stream_player.volume_db, new_volume_db, 0.5,
            Tween.TRANS_LINEAR, Tween.EASE_IN)
        _tween.start()
    else:
        _audio_stream_player.volume_db = new_volume_db
