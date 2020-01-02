extends Area2D

signal lamp_lit(lamp)
signal rested_at_lamp(lamp)

onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _fade_in_out_label: Label = $FadeInOutLabel
onready var _light_sprite: Sprite = $LightSprite
onready var _lamp_embers: Particles2D = $LampEmbers
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
                _is_lit = true

                _player.set_direction(Util.direction(_player, self))

                _fade_in_out_label.set_text('Rest')
                _light_sprite.visible = true
                _animation_player.play('unlit_to_lit')
                _animation_player.queue('lit')

                _lamp_embers.emitting = true

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

func fade_in_label() -> void:
    _fade_in_out_label.fade_in()

func fade_out_label() -> void:
    _fade_in_out_label.fade_out()