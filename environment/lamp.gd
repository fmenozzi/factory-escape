extends Area2D

signal lamp_lit(lamp)
signal rested_at_lamp(lamp)

onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _fade_in_out_label: Label = $FadeInOutLabel
onready var _light_sprite: Sprite = $LightSprite
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
                set_process_unhandled_input(false)
                _is_lit = true

                # Make sure player is facing lamp.
                _player.set_direction(Util.direction(_player, self))

                # Fade out label text so that it can be changed and faded back
                # in.
                _fade_in_out_label.fade_out()

                # Play light_lamp animation and wait for that to finish before
                # the lamp actually lights.
                #
                # TODO: This might be better served as its own state.
                var player_animation_player := _player.get_animation_player()
                player_animation_player.play('light_lamp')
                yield(player_animation_player, 'animation_finished')
                player_animation_player.play('idle')

                _light_sprite.visible = true
                _animation_player.play('unlit_to_lit')
                _animation_player.queue('lit')

                # Wait until we've started the 'lit' animation before fading in
                # new label text.
                yield(_animation_player, 'animation_started')
                _fade_in_out_label.set_text('Rest')
                _fade_in_out_label.fade_in()

                set_process_unhandled_input(true)

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