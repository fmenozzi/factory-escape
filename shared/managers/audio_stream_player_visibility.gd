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

export(Curve) var attenuation_curve: Curve

onready var _audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
onready var _object_visibility: VisibilityNotifier2D = $ObjectVisibility
onready var _attenuation_visibility: VisibilityNotifier2D = $AttenuationVisibility
onready var _object_radius: float = object_visibility_radius_tiles * Util.TILE_SIZE
onready var _attenuation_radius: float = attenuation_visibility_radius_tiles * Util.TILE_SIZE
onready var _tween: Tween = $VolumeTween

var _state: int
var _muted := false

func _ready() -> void:
    assert(attenuation_curve != null)

    # Set starting volume.
    _set_volume_db(max_volume_db)

    # Create visibility rects from radii.
    set_radii_tiles(object_visibility_radius_tiles, attenuation_visibility_radius_tiles)

    # Connect VisibilityNotifier2D signals to enable state transitions. Tween to
    # new volumes in these state transitions.
    _object_visibility.connect(
        'screen_entered', self, '_on_object_rect_screen_entered')
    _object_visibility.connect(
        'screen_exited', self, '_on_object_rect_screen_exited')
    _attenuation_visibility.connect(
        'screen_entered', self, '_on_attenuation_rect_screen_entered')
    _attenuation_visibility.connect(
        'screen_exited', self, '_on_attenuation_rect_screen_exited')

    # Set initial volume immediately here.
    set_state()

func _process(delta: float) -> void:
    var distance_to_screen_edge := _get_distance_to_closest_screen_edge()

    var w := (_attenuation_radius - distance_to_screen_edge) / (_attenuation_radius - _object_radius)

    var volume_linear := attenuation_curve.interpolate(w)

    _set_volume_db(Audio.linear_to_db(clamp(volume_linear, 0.0, 1.0), max_volume_db))

func get_player() -> AudioStreamPlayer:
    return _audio_stream_player

func set_radii_tiles(vis_radius_tiles: float, att_radius_tiles: float) -> void:
    assert(vis_radius_tiles > 0)
    assert(att_radius_tiles > 0)
    assert(vis_radius_tiles < att_radius_tiles)

    var vr := vis_radius_tiles * Util.TILE_SIZE
    var ar := att_radius_tiles * Util.TILE_SIZE

    _object_visibility.rect = Rect2(-vr, -vr, 2 * vr, 2 * vr)
    _attenuation_visibility.rect = Rect2(-ar, -ar, 2 * ar, 2 * ar)

func set_state() -> void:
    if _muted:
        return

    if _object_visibility.is_on_screen():
        _set_state(State.VISIBLE)
    elif _attenuation_visibility.is_on_screen():
        _set_state(State.ATTENUATING)
    else:
        _set_state(State.INVISIBLE)

func set_muted(muted: bool) -> void:
    _muted = muted

    if muted:
        set_process(false)
        _set_volume_db(-80.0)
    else:
        set_state()

func _set_state(new_state: int) -> void:
    assert(new_state in [State.VISIBLE, State.ATTENUATING, State.INVISIBLE])

    match new_state:
        State.VISIBLE:
            set_process(false)
            _set_volume_db(max_volume_db)

        State.ATTENUATING:
            set_process(true)

        State.INVISIBLE:
            set_process(false)
            _set_volume_db(-80.0)

    _state = new_state

func _set_volume_db(new_volume_db: float) -> void:
    _audio_stream_player.volume_db = new_volume_db

func _get_distance_to_closest_screen_edge() -> float:
    var position_screen_space := get_global_transform_with_canvas().get_origin()

    var screen_dims := Util.get_ingame_resolution()
    var width := screen_dims.x
    var height := screen_dims.y

    var distance_left := abs(position_screen_space.x)
    var distance_right := abs(width - distance_left)
    var distance_top := abs(position_screen_space.y)
    var distance_bottom := abs(height - distance_top)

    return min(min(min(distance_left, distance_right), distance_top), distance_bottom)

func _on_object_rect_screen_entered() -> void:
    if _muted:
        return

    _set_state(State.VISIBLE)

func _on_object_rect_screen_exited() -> void:
    if _muted:
        return

    _set_state(State.ATTENUATING)

func _on_attenuation_rect_screen_entered() -> void:
    if _muted:
        return

    _set_state(State.ATTENUATING)

func _on_attenuation_rect_screen_exited() -> void:
    if _muted:
        return

    _set_state(State.INVISIBLE)
