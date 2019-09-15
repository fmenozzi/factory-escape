extends Node

# The size of a basic "tile" in the game, in pixels. Distances (e.g jump 
# heights) and speeds (e.g. walk speed, fall speed) will be calculated in units
# of this tile size to make it easier to design the world around the player's
# movement capabilities (e.g. ensure that the player can clear certain jumps).
const TILE_SIZE: int = 16

# Floor normal indicating "up" direction, used in move_and_slide() so that
# future invocations of functions like is_on_floor() and is_on_wall(), etc.
# execute correctly.
const FLOOR_NORMAL: Vector2 = Vector2.UP

# Constants passed as the snap value to move_and_slide_with_snap().
const SNAP: Vector2 = 10.0 * Vector2.DOWN
const NO_SNAP: Vector2 = Vector2.ZERO

enum Direction {
    LEFT = -1,
    NONE = 0,
    RIGHT = 1,
}

# Get the current x-axis input direction. Returns +1 if player is moving right,
# -1 if player is moving left, and 0 if player is not moving.
func get_input_direction() -> int:
    # For now, just calculate movement on the x-axis.
    return int(Input.is_action_pressed('player_move_right')) - \
           int(Input.is_action_pressed('player_move_left'))

# Gets the in-game resolution from the project settings.
func get_ingame_resolution() -> Vector2:
    var w = ProjectSettings.get_setting('display/window/size/width')
    var h = ProjectSettings.get_setting('display/window/size/height')

    return Vector2(w, h)

# Start the one-shot particle effect and then wait for it to finish before
# freeing it.
func spawn_particles(particles: Particles2D, parent: Node2D) -> void:
    assert particles.one_shot

    parent.add_child(particles)

    particles.emitting = true
    yield(get_tree().create_timer(particles.lifetime * 2), 'timeout')
    particles.queue_free()

# Gets the x-direction of the "to" node relative to the "from" node.
func direction(from: Node2D, to: Node2D) -> int:
    return int(sign((to.global_position - from.global_position).x))
