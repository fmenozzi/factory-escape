extends Node2D
class_name Ability

signal ability_acquired(ability)
signal finished_playing_acquired_sound

enum Kind {
    DASH,
    DOUBLE_JUMP,
    WALL_JUMP,
    GRAPPLE,
}

enum State {
    UNACQUIRED,
    ACQUIRED,
}

export(Kind) var ability := Kind.DASH

onready var _ripple_sprite: Sprite = $Visuals/RippleSprite
onready var _animation_player: AnimationPlayer = $Visuals/AnimationPlayer
onready var _fade_in_out_label: Label = $FadeInOutLabel
onready var _label_area: Area2D = $LabelArea
onready var _walk_to_points: Node2D = $WalkToPoints
onready var _audio_group: VisibilityBasedAudioGroup = $VisibilityBasedAudioGroup
onready var _player: Player = Util.get_player()

var _state: int

func _ready() -> void:
    _ripple_sprite.set_material(_ripple_sprite.get_material().duplicate(true))

    _label_area.connect('body_entered', self, '_on_player_entered')
    _label_area.connect('body_exited', self, '_on_player_exited')

    _animation_player.play('hover')

    _state = State.UNACQUIRED

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed('player_interact'):
        if _player.get_nearby_ability() != self:
            return

        # Only allow interacting with abilities while idle or walking near them.
        if not _player.current_state() in [Player.State.IDLE, Player.State.WALK]:
            return

        # Player can only directly interact with UNACQUIRED abilities.
        if _state == State.ACQUIRED:
            return

        emit_signal('ability_acquired', self)

func hide() -> void:
    .hide()
    _animation_player.stop()

func play_idle_ping_sound() -> void:
    _audio_group.get_player_by_name('IdlePing').play()

func play_acquired_sound() -> void:
    var audio_stream_player: AudioStreamPlayer = \
        _audio_group.get_player_by_name('Acquired').get_player()
    audio_stream_player.play()
    yield(audio_stream_player, 'finished')
    emit_signal('finished_playing_acquired_sound')

func mark_as_acquired() -> void:
    _state = State.ACQUIRED

func get_closest_walk_to_point() -> Position2D:
    return _walk_to_points.get_closest_point()

func _on_player_entered(player: Player) -> void:
    if not player:
        return

    player.set_nearby_ability(self)

    if _state == State.UNACQUIRED:
        _fade_in_out_label.fade_in()

func _on_player_exited(player: Player) -> void:
    if not player:
        return

    player.set_nearby_ability(null)

    if _state == State.UNACQUIRED:
        _fade_in_out_label.fade_out()
