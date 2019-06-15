extends Node

# The size of a basic "tile" in the game. Distances (e.g jump heights) and
# speeds (e.g. walk speed, fall speed) will be calculated in units of this tile
# size to make it easier to design the world around the player's movement
# capabilities (e.g. ensure that the player can clear certain jumps).
const TILE_SIZE_PIXELS: int = 16

# Floor normal indicating "up" direction, used in move_and_slide() so that
# future invocations of functions like is_on_floor() and is_on_wall(), etc.
# execute correctly.
const FLOOR_NORMAL: Vector2 = Vector2.UP

# Get the current x-axis input direction. Returns +1 if player is moving right,
# -1 if player is moving left, and 0 if player is not moving.
func get_input_direction() -> int:
	# For now, just calculate movement on the x-axis.
	return int(Input.is_action_pressed('player_move_right')) - \
		   int(Input.is_action_pressed('player_move_left'))
		
# Gets the in-game resolution from the project settings.
func get_ingame_resolution() -> Vector2:
	var w = ProjectSettings.get_setting('display/window/size/width')
	var h = ProjectSettings.get_setting('display/window/size/height')
	
	return Vector2(w, h)