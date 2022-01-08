extends Node2D
class_name Ability

signal ability_acquired(ability)

enum Kind {
    DASH,
    DOUBLE_JUMP,
    WALL_JUMP,
    GRAPPLE,
}

export(Kind) var ability := Kind.DASH

onready var _ripple_sprite: Sprite = $Visuals/RippleSprite
onready var _animation_player: AnimationPlayer = $Visuals/AnimationPlayer
onready var _trigger_area: Area2D = $TriggerArea

func _ready() -> void:
    _ripple_sprite.set_material(_ripple_sprite.get_material().duplicate(true))

    _trigger_area.connect('body_entered', self, '_on_acquired_by_player')

    _animation_player.play('hover')

func _on_acquired_by_player(player: KinematicBody2D) -> void:
    if not player:
        return

    _trigger_area.call_deferred(
        'disconnect', 'body_entered', self, '_on_acquired_by_player')

    hide()

    emit_signal('ability_acquired', self)
