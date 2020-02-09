extends Area2D

signal lamp_lit(lamp)
signal rested_at_lamp(lamp)

onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _fade_in_out_label: Label = $FadeInOutLabel
onready var _light_sprite: Sprite = $LightSprite
onready var _left_walk_to_point: Position2D = $LeftWalkToPoint
onready var _right_walk_to_point: Position2D = $RightWalkToPoint
onready var _left_light_point: Position2D = $LeftLightPoint
onready var _right_light_point: Position2D = $RightLightPoint
onready var _player: Player = Util.get_player()

var _is_lit := false

func _ready() -> void:
    _fade_in_out_label.set_text('Light Lamp')
    _light_sprite.visible = false
    _animation_player.play('unlit')

    self.connect('body_entered', self, '_on_player_entered')
    self.connect('body_exited', self, '_on_player_exited')

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed('player_interact'):
        if _player.current_state() == Player.State.REST:
            _player.change_state({'new_state': Player.State.IDLE})
            return

        if _player.get_nearby_lamp() == self:
            if not _is_lit:
                emit_signal('lamp_lit', self)
            else:
                emit_signal('rested_at_lamp', self)

func _on_player_entered(player: Player) -> void:
    if not player:
        return

    player.set_nearby_lamp(self)

    fade_in_label()

func _on_player_exited(player: Player) -> void:
    if not player:
        return

    player.set_nearby_lamp(null)

    fade_out_label()

func light() -> void:
    _light_sprite.visible = true
    _animation_player.play('unlit_to_lit')
    _animation_player.queue('lit')

    # Wait until we've started the 'lit' animation before fading in
    # new label text.
    yield(_animation_player, 'animation_started')
    _fade_in_out_label.set_text('Rest')
    fade_in_label()

    _is_lit = true

func is_lit() -> bool:
    return _is_lit

func get_closest_walk_to_point() -> Position2D:
    var player_pos := _player.global_position

    var distance_to_left := player_pos.distance_to(
        _left_walk_to_point.global_position)
    var distance_to_right := player_pos.distance_to(
        _right_walk_to_point.global_position)

    if distance_to_left <= distance_to_right:
        return _left_walk_to_point
    else:
        return _right_walk_to_point

func get_closest_light_point() -> Position2D:
    var player_pos := _player.global_position

    var distance_to_left := player_pos.distance_to(
        _left_light_point.global_position)
    var distance_to_right := player_pos.distance_to(
        _right_light_point.global_position)

    if distance_to_left <= distance_to_right:
        return _left_light_point
    else:
        return _right_light_point

func fade_in_label() -> void:
    _fade_in_out_label.fade_in()

func fade_out_label() -> void:
    _fade_in_out_label.fade_out()
