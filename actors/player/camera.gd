extends Camera2D

signal transition_completed

const CAMERA_PAN_DISTANCE := 4.0 * Util.TILE_SIZE

onready var _player: Player = get_parent().get_parent()
onready var _tween: Tween = $PositionTween

var _is_detached := false

func detach_and_move_to_global(new_global_pos: Vector2, tween_duration := 0.0) -> void:
    # As of switching to Godot 3.3, this call to set_as_toplevel() needs to be
    # immediately followed up with a call to "reset" the global position back to
    # what it was prior to this call, as set_as_toplevel() will now update the
    # global position itself.
    var old_global_pos := self.global_position
    self.set_as_toplevel(true)
    self.global_position = old_global_pos

    _is_detached = true

    var prop := 'global_position'
    var duration := tween_duration
    var trans := Tween.TRANS_QUAD
    var easing := Tween.EASE_IN_OUT
    var old := old_global_pos
    var new := new_global_pos

    _tween.remove_all()
    _tween.interpolate_property(self, prop, old, new, duration, trans, easing)
    _tween.start()

func reattach(tween_duration := 0.50) -> void:
    # Determine our position relative to the player for the starting value of
    # the reattachment interpolation.
    self.position = _player.to_local(self.global_position)

    # As of switching to Godot 3.3, this needs to be called AFTER setting the
    # camera's position, likely because it'll now immediately go back to the
    # global position from when it was detached.
    self.set_as_toplevel(false)

    # Smoothly reattach the camera to the player by tweening to the original
    # local anchor position.
    var prop := 'position'
    var duration := tween_duration
    var trans := Tween.TRANS_QUAD
    var easing := Tween.EASE_IN_OUT
    var old := self.position
    var new := Vector2.ZERO

    _tween.remove_all()
    _tween.interpolate_property(self, prop, old, new, duration, trans, easing)
    _tween.start()

    yield(_tween, 'tween_completed')
    _is_detached = false

func pan_up() -> void:
    if _is_detached:
        return

    _pan_to_position(Vector2(0, -CAMERA_PAN_DISTANCE))

func pan_down() -> void:
    if _is_detached:
        return

    _pan_to_position(Vector2(0, CAMERA_PAN_DISTANCE))

func return_from_pan() -> void:
    if _is_detached:
        return

    _pan_to_position(Vector2.ZERO)

func transition(old_room, new_room) -> void:
    _transition_setup()

    # Interpolate camera position from current viewport center to the best spot
    # in the next room.
    var old_global_pos = get_camera_screen_center()
    var new_global_pos = _get_new_camera_global_position(old_room, new_room)

    # Move the player one pixel into the direction of the new room. This is to
    # help ensure that the room detection area does not exist in more than one
    # room at a time.
    _player.global_position += old_global_pos.direction_to(new_global_pos).normalized()

    _interpolate_camera_pos(old_global_pos, new_global_pos)

    # Remove camera limits so that camera can smoothly transition between rooms.
    # Note that we wait until the tween has started to avoid jitter when the
    # camera moves from the player anchor to the initial tween position.
    yield(_tween, 'tween_started')
    _remove_camera_limits()

    yield(_tween, 'tween_completed')
    _transition_teardown(new_room)

    emit_signal('transition_completed')

func fit_camera_limits_to_room(room: RoomFe) -> void:
    var room_dims := room.get_room_dimensions()

    self.limit_left = room.global_position.x
    self.limit_right = room.global_position.x + room_dims.x
    self.limit_top = room.global_position.y
    self.limit_bottom = room.global_position.y + room_dims.y

func _transition_setup() -> void:
    # Pause player processing (physics and input processing, animations, state
    # timers, etc.)
    _player.pause()

    # Disable smoothing to avoid jitter during transition.
    self.smoothing_enabled = false

    # In case we're currently in the process of returning from pan, cancel the
    # tween and reset the position immediately.
    _tween.reset_all()
    _tween.remove_all()
    self.position = Vector2.ZERO

func _transition_teardown(room: RoomFe) -> void:
    # Restore local camera position.
    self.position = Vector2.ZERO

    # Adjust camera limits to match room dimensions.
    self.fit_camera_limits_to_room(room)

    # Re-enable smoothing now that the transition has completed.
    self.smoothing_enabled = true

    # Restore player processing.
    _player.unpause()

func _get_transition_direction(old_room, new_room) -> Vector2:
    var old_room_bounds: Rect2 = old_room.get_room_bounds()
    var new_room_bounds: Rect2 = new_room.get_room_bounds()

    if old_room_bounds.end.x == new_room_bounds.position.x:
        return Vector2.RIGHT
    elif old_room_bounds.position.x == new_room_bounds.end.x:
        return Vector2.LEFT
    elif old_room_bounds.end.y == new_room_bounds.position.y:
        return Vector2.DOWN
    elif old_room_bounds.position.y == new_room_bounds.end.y:
        return Vector2.UP

    return Vector2.ZERO

func _get_new_camera_global_position(old_room, new_room) -> Vector2:
    var current_camera_position := global_position
    var anchor: Vector2 = new_room.get_closest_camera_anchor(_player)
    var new_room_bounds: Rect2 = new_room.get_room_bounds()
    var half_screen_size := Util.get_ingame_resolution() / 2

    # The general direction that the player will move in during the room
    # transition (one of Vector2.{UP, DOWN, LEFT, RIGHT}).
    var transition_direction := _get_transition_direction(old_room, new_room)

    match transition_direction:
        Vector2.LEFT, Vector2.RIGHT:
            var candidate := Vector2(anchor.x, current_camera_position.y)
            if candidate.y + half_screen_size.y > (new_room_bounds.position.y + new_room_bounds.size.y):
                candidate.y = anchor.y
            if candidate.y - half_screen_size.y < new_room_bounds.position.y:
                candidate.y = anchor.y
            return candidate

        Vector2.UP, Vector2.DOWN:
            var candidate := Vector2(current_camera_position.x, anchor.y)
            if candidate.x + half_screen_size.x > (new_room_bounds.position.x + new_room_bounds.size.x):
                candidate.x = anchor.x
            if candidate.x - half_screen_size.x < (new_room_bounds.position.x):
                candidate.x = anchor.x
            return candidate

    return Vector2.ZERO

func _interpolate_camera_pos(old_global_pos, new_global_pos) -> void:
    var prop := 'position'
    var duration := 0.50
    var trans := Tween.TRANS_QUAD
    var easing := Tween.EASE_IN_OUT

    # Convert tween start and end position from global to local coordinates.
    var old := self.to_local(old_global_pos)
    var new := self.to_local(new_global_pos)

    _tween.remove_all()
    _tween.interpolate_property(self, prop, old, new, duration, trans, easing)
    _tween.start()

func _remove_camera_limits() -> void:
    self.limit_left = -10000000
    self.limit_right = 10000000
    self.limit_top = -10000000
    self.limit_bottom = 10000000

func _pan_to_position(new_position: Vector2) -> void:
    var prop := 'position'
    var duration := 0.25
    var trans := Tween.TRANS_QUAD
    var easing := Tween.EASE_IN_OUT
    var old := self.position
    var new := new_position

    _tween.remove_all()
    _tween.interpolate_property(self, prop, old, new, duration, trans, easing)
    _tween.start()
