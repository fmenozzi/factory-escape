extends Node

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
    'player_room_detector': 10,
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

# Convenience methods for checking whether a given collision object is in a
# layer with any of the given names. Note the lack of type for the
# collision_object param and the extra assert on the existence of the
# get_collision_layer_bit() method; it turns out that that method is defined
# separately in both KinematicBody2D and Area2D, despite both of those classes
# inheriting from CollisionObject2D.
func in_layer(collision_object, layer_name: String) -> bool:
    return in_layers(collision_object, [layer_name])
func in_layers(collision_object, layer_names: Array) -> bool:
    assert(collision_object.has_method('get_collision_layer_bit'))
    for layer_name in layer_names:
        assert(layer_name in _LAYER_NAMES)
        if collision_object.get_collision_layer_bit(_LAYER_NAMES[layer_name]):
            return true
    return false

func set_mask(collision_object, mask_name: String, val: bool) -> void:
    assert(collision_object.has_method('set_collision_mask_bit'))

    collision_object.set_collision_mask_bit(_LAYER_NAMES[mask_name], val)
