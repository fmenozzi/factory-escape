extends Camera2D

onready var _player: Player = get_parent().get_parent()
onready var _tween: Tween = $GlobalPositionTween

var _original_local_anchor_pos = 0
	
func transition(old_room, new_room) -> void:
	_tween.connect('tween_completed', self, '_on_tween_completed', [new_room])
	_tween.connect('tween_started', self, '_on_tween_started')
	
	_player.pause()
	
	# Save the original local position of the camera relative to the anchor so
	# that we can 
	_original_local_anchor_pos = self.position
	
	# Disable smoothing to avoid jitter during transition.
	self.smoothing_enabled = false
	
	# Find closest camera anchors in both previous and current room and use
	# their positions as interpolation points for camera position.
	var old_global_pos = old_room.get_closest_camera_anchor(_player)
	var new_global_pos = new_room.get_closest_camera_anchor(_player)
	_interpolate_camera_pos(old_global_pos, new_global_pos)
	
func fit_camera_limits_to_room(room: Room) -> void:
	var room_dims := room.get_room_dimensions()
	
	self.limit_left = room.global_position.x
	self.limit_right = room.global_position.x + room_dims.x
	self.limit_top = room.global_position.y
	self.limit_bottom = room.global_position.y + room_dims.y
	
func _interpolate_camera_pos(old_global_pos, new_global_pos) -> void:
	var prop := 'position'
	var duration := 0.50
	var trans := Tween.TRANS_QUAD
	var easing := Tween.EASE_IN_OUT
	
	# Convert tween start and end position from global to local coordinates.
	var old = self.position - (self.global_position - old_global_pos)
	var new = self.position + (new_global_pos - self.global_position)
	
	_tween.stop_all()
	_tween.interpolate_property(self, prop, old, new, duration, trans, easing)
	_tween.start()

func _on_tween_completed(object: Object, key: NodePath, room: Room) -> void:
	_tween.disconnect('tween_completed', self, '_on_tween_completed')
	
	# Restore local camera position to the original anchor point.
	self.position = _original_local_anchor_pos
	
	# Adjust camera limits to match room dimensions.
	self.fit_camera_limits_to_room(room)
	
	# Re-enable smoothing now that the transition has completed.
	self.smoothing_enabled = true
	
	_player.unpause()
	
func _on_tween_started(object: Object, key: NodePath) -> void:
	# Remove camera limits so that camera can smoothly transition between rooms.
	# Note that we wait until the tween has started to avoid jitter when the
	# camera moves from the player anchor to the initial tween position.
	self.limit_left = -10000000
	self.limit_right = 10000000
	self.limit_top = -10000000
	self.limit_bottom = 10000000
