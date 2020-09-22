extends Node2D
class_name Room

onready var _camera_anchors: Array = $CameraAnchors.get_children()
onready var _grapple_points: Array = $GrapplePoints.get_children()
onready var _moving_platforms: Array = $MovingPlatforms.get_children()
onready var _enemies: Node2D = $Enemies
onready var _tilemaps_nav: Navigation2D = $TileMaps

func _ready() -> void:
    _connect_projectile_spawner_signals()

    pause()

# Get global positions of all camera anchors in each room. During a transition,
# the player camera will interpolate its position from the closest anchor in
# the old room to the closest anchor in the new room.
func get_camera_anchors() -> Array:
    var anchors = []
    for anchor in _camera_anchors:
        anchors.push_back(anchor.global_position)
    return anchors

func get_closest_camera_anchor(player: Player) -> Vector2:
    var player_pos := player.global_position

    var min_dist := INF
    var min_dist_anchor := Vector2()

    for anchor in self.get_camera_anchors():
        var dist := player_pos.distance_to(anchor)
        if dist < min_dist:
            min_dist = dist
            min_dist_anchor = anchor

    return min_dist_anchor

# Get all the GrapplePoint nodes in the current room.
func get_grapple_points() -> Array:
    var grapple_points = []
    for grapple_point in _grapple_points:
        grapple_points.push_back(grapple_point)
    return grapple_points

# TODO: Investigate why the collision shape is sometimes null when cached using
#       onready (seems to always only occur in standalone playground rooms).
#       Maybe it has something to do with the fact that Room is a base scene?
func get_room_dimensions() -> Vector2:
    var half_extents = get_node('RoomBoundaries/CollisionShape2D').shape.extents

    return 2 * half_extents

func get_moving_platforms() -> Array:
    return _moving_platforms

func get_tilemaps_nav() -> Navigation2D:
    return _tilemaps_nav

func pause() -> void:
    for moving_platform in get_moving_platforms():
        moving_platform.pause()

    for enemy in $Enemies.get_children():
        enemy.pause()

func resume() -> void:
    for moving_platform in get_moving_platforms():
        moving_platform.resume()

    for enemy in $Enemies.get_children():
        enemy.resume()

func contains(obj: Node2D) -> bool:
    var bounds := Rect2(get_global_position(), get_room_dimensions())

    return bounds.has_point(obj.get_global_position())

# TODO: This general idea could probably be improved by having projectile
#       spawners figure out which room they're in (by walking up the tree) and
#       connecting their signals to that room. This could happen in each
#       spawner's _ready() function, eliminating the need to call this function
#       manually.
func _connect_projectile_spawner_signals() -> void:
    for spawner in get_tree().get_nodes_in_group('projectile_spawners'):
        # Only connect the spawners in this room to this room's callbacks.
        if spawner.find_parent(self.name) == null:
            continue

        spawner.connect(
            'homing_projectile_fired', self, '_on_homing_projectile_fired',
            [spawner])
        spawner.connect(
            'energy_projectile_fired', self, '_on_energy_projectile_fired',
            [spawner])

func _on_homing_projectile_fired(
    global_pos: Vector2, dir: Vector2, spawner: ProjectileSpawner
) -> void:
    var homing_projectile: HomingProjectile = Preloads.HomingProjectile.instance()
    _enemies.add_child(homing_projectile)

    spawner.connect(
        'projectile_spawner_destroyed', homing_projectile,
        '_on_projectile_spawner_destroyed')

    homing_projectile.global_position = global_pos
    homing_projectile.start(dir)

func _on_energy_projectile_fired(
    global_pos: Vector2, dir: Vector2, spawner: ProjectileSpawner
) -> void:
    var energy_projectile: EnergyProjectile = Preloads.EnergyProjectile.instance()
    _enemies.add_child(energy_projectile)

    energy_projectile.global_position = global_pos
    energy_projectile.start(dir)
