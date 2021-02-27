extends Node2D
class_name Room

onready var _room_boundaries: Area2D = $RoomBoundaries
onready var _camera_anchors: Array = $CameraAnchors.get_children()
onready var _grapple_points: Array = $GrapplePoints.get_children()
onready var _moving_platforms: Array = $MovingPlatforms.get_children()
onready var _enemies: Node2D = $Enemies
onready var _tilemaps_nav: Navigation2D = $TileMaps

func _ready() -> void:
    _room_boundaries.connect('area_entered', self, '_on_player_entered')

    _connect_projectile_spawner_signals()

    pause()
    set_enemies_visible(false)

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

    for hazard in $Hazards.get_children():
        hazard.pause()

    for enemy in $Enemies.get_children():
        enemy.pause()

func resume() -> void:
    for moving_platform in get_moving_platforms():
        moving_platform.resume()

    for hazard in $Hazards.get_children():
        hazard.resume()

    for enemy in $Enemies.get_children():
        enemy.resume()

func reset_enemies() -> void:
    for enemy in $Enemies.get_children():
        enemy.room_reset()

func set_enemies_visible(enemies_visible: bool) -> void:
    for enemy in $Enemies.get_children():
        if enemy is EnergyProjectile or enemy is HomingProjectile:
            continue

        if not enemy.is_dead():
            enemy.visible = enemies_visible

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

    spawner.connect(
        'projectile_spawner_destroyed', energy_projectile,
        '_on_projectile_spawner_destroyed')

    energy_projectile.global_position = global_pos
    energy_projectile.start(dir)

func _on_player_entered(area: Area2D) -> void:
    var player: Player = area.get_parent()
    assert(player != null)

    var camera := player.get_camera()

    # Transition to room once we enter a new one.
    if player.curr_room != self:
        player.prev_room = player.curr_room
        player.curr_room = self

        player.curr_room.set_enemies_visible(true)

        # Pause processing on the old room, transition to the new one, and
        # then begin processing on the new room once the transition is
        # complete.
        player.prev_room.pause()
        camera.transition(player.prev_room, player.curr_room)
        yield(camera, 'transition_completed')
        player.curr_room.resume()

        # Reset and hide enemies in the previous room once the transition
        # completes.
        player.prev_room.reset_enemies()
        player.prev_room.set_enemies_visible(false)
