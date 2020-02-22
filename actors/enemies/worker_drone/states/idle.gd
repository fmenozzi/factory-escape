extends 'res://actors/enemies/state.gd'

const NUM_ATTEMPTS_TO_FIND_NEXT_POINT := 10

var _room: Room = null

onready var _idle_duration_timer: Timer = $IdleDurationTimer

func _ready() -> void:
    _idle_duration_timer.one_shot = true

func enter(worker_drone: WorkerDrone, previous_state_dict: Dictionary) -> void:
    _idle_duration_timer.start()

    _room = worker_drone.get_parent().get_parent()
    assert(_room != null)

    _idle_duration_timer.wait_time = rand_range(0.5, 2.0)

func exit(worker_drone: WorkerDrone) -> void:
    pass

func update(worker_drone: WorkerDrone, delta: float) -> Dictionary:
    if _idle_duration_timer.is_stopped():
        # Once we finish idling, pick a random point within the room to fly to.
        return {
            'new_state': WorkerDrone.State.FLY_TO_POINT,
            'fly_to_point': _get_next_fly_to_point(worker_drone),
        }

    return {'new_state': WorkerDrone.State.NO_CHANGE}

func _get_next_fly_to_point(worker_drone: WorkerDrone) -> Vector2:
    var obstacle_detector := worker_drone.get_obstacle_detector()

    var room_dims := _room.get_room_dimensions()
    var global_room_pos := _room.to_global(_room.position)

    # Attempt to find a point in the room with an unobstructed line of sight.
    # Limit the number of attempts so that we don't hang in update() if the
    # drone potentially finds itself in a corner or something.
    var global_fly_to_point := Vector2.ZERO
    for i in range(NUM_ATTEMPTS_TO_FIND_NEXT_POINT):
        global_fly_to_point = Vector2(
            rand_range(global_room_pos.x, global_room_pos.x + room_dims.x),
            rand_range(global_room_pos.y, global_room_pos.y + room_dims.y))
        obstacle_detector.cast_to = worker_drone.to_local(global_fly_to_point)
        if obstacle_detector.is_colliding():
            continue
    return global_fly_to_point
