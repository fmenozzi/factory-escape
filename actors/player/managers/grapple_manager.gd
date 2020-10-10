extends Node2D
class_name GrappleManager

const SAVE_KEY := 'grapple_manager'

var _has_grapple := false

onready var _grapple_rope: Line2D = $GrappleRope
onready var _grapple_hook: Sprite = $GrappleHook
onready var _grapple_line_of_sight: RayCast2D = $GrappleLineOfSight

# The grapple point to be used the next time the player presses the grapple
# button. This is updated on every frame (in the parent player script) based on
# several candidacy rules. If there are no valid grapple points for the player
# on a given frame, this is set to null and grappling has no effect.
var _next_grapple_point: GrapplePoint = null

func get_save_data() -> Array:
    return [SAVE_KEY, {
        'has_grapple': _has_grapple,
    }]

func load_save_data(all_save_data: Dictionary) -> void:
    if not SAVE_KEY in all_save_data:
        return

    var grapple_manager_save_data: Dictionary = all_save_data[SAVE_KEY]
    assert('has_grapple' in grapple_manager_save_data)

    _has_grapple = grapple_manager_save_data['has_grapple']

func update_next_grapple_point(player, curr_room) -> void:
    _next_grapple_point = null

    var current_room_grapple_points: Array = curr_room.get_grapple_points()
    if current_room_grapple_points.empty():
        return

    # Determine candidate set of grapple points and reset grapple point colors.
    var candidate_grapple_points := []
    for grapple_point in current_room_grapple_points:
        grapple_point.get_node('Sprite').modulate = Color.white
        if _can_grapple_to(grapple_point, player):
            candidate_grapple_points.append(grapple_point)

    if candidate_grapple_points.empty():
        return

    # Sort candidate grapple points by distance to player.
    candidate_grapple_points.sort_custom(self, '_grapple_distance_comparator')

    # Pick the first grapple point that the player is facing. If the player is
    # facing away from all available grapple points, pick the closest one.
    _next_grapple_point = candidate_grapple_points[0]
    for grapple_point in candidate_grapple_points:
        var grapple_point_direction := Util.direction(self, grapple_point)
        if player.get_direction() == grapple_point_direction:
            _next_grapple_point = grapple_point
            break

    # Color the next grapple point green.
    if _next_grapple_point:
        _next_grapple_point.get_node('Sprite').modulate = Color.green

func get_next_grapple_point() -> GrapplePoint:
    return _next_grapple_point

func get_grapple_rope() -> Line2D:
    return _grapple_rope

func get_grapple_hook() -> Sprite:
    return _grapple_hook

func _grapple_point_in_line_of_sight(grapple_point: GrapplePoint) -> bool:
    _grapple_line_of_sight.set_cast_to(
        _grapple_line_of_sight.to_local(
            grapple_point.get_attachment_pos().global_position))
    _grapple_line_of_sight.force_raycast_update()
    return not _grapple_line_of_sight.is_colliding()

func _grapple_point_in_range(grapple_point: GrapplePoint, player) -> bool:
    return grapple_point.get_grapple_range_area().overlaps_body(player)

func _player_in_no_grapple_area(grapple_point: GrapplePoint, player) -> bool:
    return grapple_point.get_no_grapple_area().overlaps_body(player)

func _grapple_point_on_screen(grapple_point: GrapplePoint) -> bool:
    return grapple_point.is_on_screen()

func _can_grapple_to(grapple_point: GrapplePoint, player) -> bool:
    if not _has_grapple:
        return false

    if not grapple_point.is_available():
        return false

    if not _grapple_point_in_line_of_sight(grapple_point):
        return false

    if not _grapple_point_in_range(grapple_point, player):
        return false

    if _player_in_no_grapple_area(grapple_point, player):
        return false

    if not _grapple_point_on_screen(grapple_point):
        return false

    return true

func _grapple_distance_comparator(a: GrapplePoint, b: GrapplePoint) -> bool:
    var distance_to_a := a.global_position.distance_to(self.global_position)
    var distance_to_b := b.global_position.distance_to(self.global_position)
    return distance_to_a < distance_to_b

func _on_ability_chosen(chosen_ability: int) -> void:
    assert(chosen_ability in [
        DemoAbility.Ability.DASH,
        DemoAbility.Ability.DOUBLE_JUMP,
        DemoAbility.Ability.GRAPPLE,
        DemoAbility.Ability.WALL_JUMP
    ])

    if chosen_ability == DemoAbility.Ability.GRAPPLE:
        _has_grapple = true
