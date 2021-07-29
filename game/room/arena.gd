extends Node2D
class_name Arena

onready var _enemies_node: Node2D = get_parent().get_node('Enemies')
onready var _phases: Node2D = $Phases
onready var _num_phases: int = $Phases.get_child_count()
onready var _closing_doors: Array = $ClosingDoors.get_children()
onready var _trigger: Area2D = $Trigger
onready var _camera_anchor: Position2D = $CameraAnchor
onready var _save_manager: Node = $SaveManager

var _phase_data := []
var _player_camera: Camera2D = null

func _ready() -> void:
    assert(get_parent() is Room)

    _assert_phase_structure_is_correct()
    _assert_closing_doors_structure_is_correct()

    # Remove enemies/phases from the tree and instead save them in an array so
    # that they can be spawned dynamically at the same position in which they
    # were placed in the editor. The array is indexed by phase, and each element
    # is itself an array of dictionaries (one per enemy in that phase).
    for phase in _phases.get_children():
        _phase_data.append([])
        for enemy in phase.get_children():
            _phase_data.back().append({
                'enemy': enemy,
                'spawn_point_local': enemy.position,
            })
            phase.remove_child(enemy)
        _phases.remove_child(phase)

    _trigger.connect('body_entered', self, '_start_arena')

    set_process(false)

func _process(delta: float) -> void:
    if _arena_started():
        # Pin the player camera to the camera anchor and close all the doors.
        _player_camera.detach_and_move_to_global(self.to_global(_camera_anchor.position))
        _close_all_doors()

    if _num_live_enemies() == 0:
        _save_manager.current_phase_index += 1

        if _arena_finished():
            # Finish once all phases are completed.
            _finish_arena()
            return

        _spawn_enemies_for_phase(_save_manager.current_phase_index)

func lamp_reset() -> void:
    set_process(false)

    _open_all_doors()

    # Despawn all enemies in case the player dies during the arena fight.
    for enemy in _enemies_node.get_children():
        _enemies_node.remove_child(enemy)

    # Unless the player has already completed the arena, reset to PRE_FIGHT
    # state on lamp rest (e.g. if the player dies in the middle of the fight).
    if not _arena_finished():
        _save_manager.current_phase_index = -1

        # In case the player died while the camera was detached in the middle
        # of the arena fight, reattach the camera without tweening it (i.e. set
        # the camera's position to (0, 0) immediately). If the player dies
        # before reaching the arena, the player camera will be null.
        if _player_camera != null:
            _player_camera.reattach(false)

func _start_arena(player: Player) -> void:
    if not player:
        return

    if _save_manager.current_phase_index != -1:
        return

    _player_camera = player.get_camera()
    assert(_player_camera != null)

    set_process(true)

func _finish_arena() -> void:
    # Open the doors, shake the screen slightly as the doors open, then reattach
    # the camera.
    set_process(false)
    _open_all_doors()
    Screenshake.start(
        Screenshake.Duration.LONG, Screenshake.Amplitude.VERY_SMALL,
        Screenshake.Priority.HIGH)
    Rumble.start(Rumble.Type.WEAK, 0.5, Rumble.Priority.HIGH)
    yield(Screenshake, 'stopped_shaking')
    _player_camera.reattach()

func _spawn_enemies_for_phase(phase_idx: int) -> void:
    var enemy_data_for_phase: Array = _phase_data[phase_idx]
    for enemy_data in enemy_data_for_phase:
        assert(enemy_data is Dictionary)
        assert('enemy' in enemy_data)
        assert('spawn_point_local' in enemy_data)
        _spawn_enemy_at(enemy_data['enemy'], enemy_data['spawn_point_local'])

    # TODO: Move this logic elsewhere.
    get_parent()._connect_projectile_spawner_signals()

func _spawn_enemy_at(enemy: Node2D, spawn_point_local: Vector2) -> void:
    # Tween transparency so that enemies fade in as they spawn.
    var prop := 'modulate'
    var old := Color(1, 1, 1, 0) # Transparent
    var new := Color(1, 1, 1, 1) # Opaque
    var duration := 0.5

    var alpha_tween := Tween.new()
    alpha_tween.interpolate_property(enemy, prop, old, new, duration)
    enemy.add_child(alpha_tween)

    _enemies_node.add_child(enemy)
    enemy.position = spawn_point_local
    alpha_tween.start()

func _close_all_doors() -> void:
    for closing_door in _closing_doors:
        closing_door.close()

func _open_all_doors() -> void:
    for closing_door in _closing_doors:
        closing_door.open()

func _num_live_enemies() -> int:
    var num_live_enemies := 0
    for enemy in _enemies_node.get_children():
        if enemy is EnergyProjectile or enemy is HomingProjectile or enemy.is_dead():
            continue
        num_live_enemies += 1
    return num_live_enemies

func _arena_started() -> bool:
    return _save_manager.current_phase_index == -1

func _arena_finished() -> bool:
    return _save_manager.current_phase_index >= _num_phases

func _assert_phase_structure_is_correct() -> void:
    assert(_num_phases > 0)

    for phase in _phases.get_children():
        assert(phase is Node2D)

        assert(phase.get_child_count() > 0)
        for enemy in phase.get_children():
            assert(enemy is KinematicBody2D or enemy is Turret)

func _assert_closing_doors_structure_is_correct() -> void:
    assert(not _closing_doors.empty())

    for closing_door in _closing_doors:
        assert(closing_door is StaticBody2D)
        assert(closing_door.has_method('open') and closing_door.has_method('close'))
