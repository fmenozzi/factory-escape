extends Node2D

signal direction_changed_to(new_direction)

export(Util.Direction) var direction := Util.Direction.LEFT

onready var _animation_player: AnimationPlayer = $AnimationPlayer

# Treat the lever as an enemy as far as hit detection is concerned.
#
# TODO: This is pretty hacky; we have to include this method because the player
#       script assumes in its _on_attack_connected() method that its attack is
#       connecting with an enemy, and therefore calls the enemy's take_hit()
#       method. Consider a refactor that allows the player to use attacks as
#       interactions and change _on_attack_connected() (and this method)
#       accordingly.
func take_hit(damage: int, player: Player) -> void:
    match direction:
        Util.Direction.LEFT:
            change_direction_to(Util.Direction.RIGHT)

        Util.Direction.RIGHT:
            change_direction_to(Util.Direction.LEFT)

func change_direction_to(new_direction: int) -> void:
    match new_direction:
        Util.Direction.LEFT:
            _animation_player.play_backwards('left_to_right')

        Util.Direction.RIGHT:
            _animation_player.play('left_to_right')

    direction = new_direction

    emit_signal('direction_changed_to', direction)
