extends Node2D
class_name ElevatorArena

signal elevator_arena_finished

onready var _room: RoomFe = get_parent()
onready var _enemies_node: Node2D = get_parent().get_node('Enemies')
onready var _phases: Node2D = $Phases
onready var _num_phases: int = $Phases.get_child_count()

var _current_phase_idx := -1
var _phase_data := []

func _ready() -> void:
    assert(_room != null)

    _assert_phase_structure_is_correct()

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

    set_process(false)

func _process(delta: float) -> void:
    if _num_live_enemies() == 0:
        _current_phase_idx += 1

        if _arena_finished():
            # Finish once all phases are completed.
            _finish_arena()
            return

        _spawn_enemies_for_phase(_current_phase_idx)

func _exit_tree() -> void:
    for phase in _phase_data:
        for enemy in phase:
            enemy['enemy'].queue_free()
        phase.clear()
    _phase_data.clear()

func start() -> void:
    set_process(true)

func lamp_reset() -> void:
    set_process(false)

    # Reset phase.
    _current_phase_idx = -1

    # Despawn all enemies in case the player dies during the arena fight.
    for enemy in _enemies_node.get_children():
        _enemies_node.remove_child(enemy)

func _finish_arena() -> void:
    set_process(false)

    emit_signal('elevator_arena_finished')

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
    _enemies_node.add_child(enemy)
    enemy.position = spawn_point_local
    enemy.spawn()

func _num_live_enemies() -> int:
    var num_live_enemies := 0
    for enemy in _enemies_node.get_children():
        if enemy is EnergyProjectile or enemy is HomingProjectile or enemy.is_dead():
            continue
        num_live_enemies += 1
    return num_live_enemies

func _arena_finished() -> bool:
    return _current_phase_idx >= _num_phases

func _assert_phase_structure_is_correct() -> void:
    assert(_num_phases > 0)

    for phase in _phases.get_children():
        assert(phase is Node2D)

        assert(phase.get_child_count() > 0)
        for enemy in phase.get_children():
            assert(enemy is KinematicBody2D or enemy is Turret)
