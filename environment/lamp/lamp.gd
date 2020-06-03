extends Area2D

signal lamp_lit(lamp)
signal rested_at_lamp(lamp)
signal lit_animation_started

onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _fade_in_out_label: Label = $FadeInOutLabel
onready var _ripple_sprite: Sprite = $RippleSprite
onready var _light_sprite: Sprite = $LightSprite
onready var _rest_walk_to_points: Node2D = $RestPoints
onready var _light_walk_to_points: Node2D = $LightPoints
onready var _player: Player = Util.get_player()

var _is_lit := false

func _ready() -> void:
    # Make sure each instance gets its own shader materials.
    _ripple_sprite.set_material(_ripple_sprite.get_material().duplicate(true))
    _light_sprite.set_material(_light_sprite.get_material().duplicate(true))

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

    emit_signal('lit_animation_started')

    _is_lit = true

func is_lit() -> bool:
    return _is_lit

func get_closest_rest_walk_to_point() -> Position2D:
    return _rest_walk_to_points.get_closest_point()

func get_closest_light_walk_to_point() -> Position2D:
    return _light_walk_to_points.get_closest_point()

func fade_in_label() -> void:
    _fade_in_out_label.fade_in()

func fade_out_label() -> void:
    _fade_in_out_label.fade_out()
