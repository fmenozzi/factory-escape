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

# Maps collision layer names to their bit indices, to be used in conjunction
# with calls to get_collision_layer_bit() in the in_collision_layer() function
# below.
const _LAYER_NAMES := {
    'player': 0,
    'enemy': 1,
    'environment': 2,
    'grapple_range_area': 3,
    'player_hitbox': 4,
    'player_hurtbox': 5,
    'enemy_hitbox': 6,
    'enemy_hurtbox': 7,
    'hazards': 8,
    'enemy_barrier': 9,
}

func _ready() -> void:
    # Assert that the layer names/bits in _LAYER_NAMES are correct by comparing
    # to the project settings. Note that layers use 1-based indexing in the
    # project settings, despite the fact that the bits themselves start at 0.
    var i := 1
    for layer_name in _LAYER_NAMES:
        var layer_path := str('layer_names/2d_physics/layer_', i)

        assert(_LAYER_NAMES[layer_name] == i-1)
        assert(ProjectSettings.get_setting(layer_path) == layer_name)

        i += 1

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
    assert(particles.one_shot)

    parent.add_child(particles)

    particles.emitting = true
    yield(get_tree().create_timer(particles.lifetime * 2), 'timeout')
    particles.queue_free()

# Gets the x-direction of the "to" node relative to the "from" node.
func direction(from: Node2D, to: Node2D) -> int:
    return int(sign((to.global_position - from.global_position).x))

# Convenience methods for checking whether a given collision object is in a
# layer with any of the given names. Note the lack of type for the
# collision_object param and the extra assert on the existence of the
# get_collision_layer_bit() method; it turns out that that method is defined
# separately in both KinematicBody2D and Area2D, despite both of those classes
# inheriting from CollisionObject2D.
func in_collision_layer(collision_object, layer_name: String) -> bool:
    return in_collision_layers(collision_object, [layer_name])
func in_collision_layers(collision_object, layer_names: Array) -> bool:
    assert(collision_object.has_method('get_collision_layer_bit'))
    for layer_name in layer_names:
        assert(layer_name in _LAYER_NAMES)
        if collision_object.get_collision_layer_bit(_LAYER_NAMES[layer_name]):
            return true
    return false
