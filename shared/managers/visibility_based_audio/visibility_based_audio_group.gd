extends Node2D
class_name VisibilityBasedAudioGroup

enum State {
    VISIBLE,
    ATTENUATING,
    INVISIBLE,
}

export(float, 0.0, 32.0) var object_visibility_radius_tiles := 0.5
export(float, 0.0, 32.0) var attenuation_visibility_radius_tiles := 1.0

export(Curve) var attenuation_curve: Curve

onready var _audio_players: Array = $AudioPlayers.get_children()
onready var _object_visibility: VisibilityNotifier2D = $ObjectVisibility
onready var _attenuation_visibility: VisibilityNotifier2D = $AttenuationVisibility
onready var _tween: Tween = $VolumeTween

var _state: int
var _att_radius: float
var _obj_radius: float
var _muted := false

func _ready() -> void:
    assert(attenuation_curve != null)
    assert(not _audio_players.empty())
    for audio_player in _audio_players:
        assert(audio_player is VisibilityBasedAudioPlayer)

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

    var w := (_att_radius - distance_to_screen_edge) / (_att_radius - _obj_radius)

    var volume_linear := attenuation_curve.interpolate(w)

    _set_all_volumes_from_linear(clamp(volume_linear, 0.0, 1.0))

func get_player_by_name(player_name: String) -> AudioStreamPlayer:
    for audio_player in _audio_players:
        if audio_player.name == player_name:
            return audio_player.get_player()

    return null

func get_player_by_index(idx: int) -> AudioStreamPlayer:
    assert(0 <= idx and idx < _audio_players.size())

    return _audio_players[idx].get_player()

func set_radii_tiles(vis_radius_tiles: float, att_radius_tiles: float) -> void:
    assert(vis_radius_tiles > 0)
    assert(att_radius_tiles > 0)
    assert(vis_radius_tiles < att_radius_tiles)

    _obj_radius = vis_radius_tiles * Util.TILE_SIZE
    _att_radius = att_radius_tiles * Util.TILE_SIZE

    _object_visibility.rect = Rect2(-_obj_radius, -_obj_radius, 2 * _obj_radius, 2 * _obj_radius)
    _attenuation_visibility.rect = Rect2(-_att_radius, -_att_radius, 2 * _att_radius, 2 * _att_radius)

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
        _set_all_volumes_to_muted()
    else:
        set_state()

func _set_state(new_state: int) -> void:
    assert(new_state in [State.VISIBLE, State.ATTENUATING, State.INVISIBLE])

    match new_state:
        State.VISIBLE:
            set_process(false)
            _set_all_volumes_to_max()

        State.ATTENUATING:
            set_process(true)

        State.INVISIBLE:
            set_process(false)
            _set_all_volumes_to_muted()

    _state = new_state

func _set_all_volumes_to_max() -> void:
    for audio_player in _audio_players:
        audio_player.set_volume_db(audio_player.max_volume_db)

func _set_all_volumes_to_muted() -> void:
    for audio_player in _audio_players:
        audio_player.set_volume_db(-80.0)

func _set_all_volumes_from_linear(volume_linear: float) -> void:
    for audio_player in _audio_players:
        audio_player.set_volume_db(
            Audio.linear_to_db(volume_linear, audio_player.max_volume_db))

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
