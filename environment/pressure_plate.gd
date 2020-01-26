extends Node2D

signal pressed
signal released

enum State {
    PRESSED,
    RELEASED,
}
var _state: int = State.RELEASED

onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _trigger_area: Area2D = $TriggerArea

func _ready() -> void:
    _trigger_area.connect('body_entered', self, '_on_body_entered')
    _trigger_area.connect('body_exited', self, '_on_body_exited')

func _on_body_entered(body: KinematicBody2D) -> void:
    # Only activate the pressure plate the first time a body presses it (i.e. if
    # another body presses it while the first one is still on it, don't cause
    # the plate to be reactivated).
    if not body or _state == State.PRESSED:
        return

    _state = State.PRESSED
    _animation_player.play('pressed')
    emit_signal('pressed')

func _on_body_exited(body: KinematicBody2D) -> void:
    # Only release the pressure plate when the last body steps off. Note that
    # we compare to 1 and not 0 because the last body will still apparently be
    # overlapping with the trigger area when we get to this callback.
    if not body or _trigger_area.get_overlapping_bodies().size() > 1:
        return

    _state = State.RELEASED
    _animation_player.play('released')
    emit_signal('released')