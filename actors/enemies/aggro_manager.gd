extends Node2D
class_name AggroManager

export(float) var aggro_radius_tiles := 0.0
export(float) var unaggro_radius_tiles := 0.0

onready var _line_of_sight: RayCast2D = $LineOfSight

onready var _aggro_area: Area2D = $AggroArea
onready var _aggro_collision_shape: CollisionShape2D = $AggroArea/CollisionShape2D

onready var _unaggro_area: Area2D = $UnaggroArea
onready var _unaggro_collision_shape: CollisionShape2D = $UnaggroArea/CollisionShape2D

func _ready() -> void:
    _aggro_collision_shape.shape.radius = aggro_radius_tiles * Util.TILE_SIZE
    _unaggro_collision_shape.shape.radius = unaggro_radius_tiles * Util.TILE_SIZE

func in_aggro_range(player: Player = Util.get_player()) -> bool:
    assert(player != null)

    return _aggro_area.overlaps_body(player)

func in_unaggro_range(player: Player = Util.get_player()) -> bool:
    assert(player != null)

    return _unaggro_area.overlaps_body(player)

func can_see_player(player: Player = Util.get_player()) -> bool:
    _line_of_sight.cast_to = _line_of_sight.to_local(player.get_center())
    _line_of_sight.force_raycast_update()

    return not _line_of_sight.is_colliding()
