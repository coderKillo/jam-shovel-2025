class_name PlayerCamera
extends Camera2D

const CAMERA_MAX_ZOOM = 1.0
const CAMERA_MIN_ZOOM = 2.0
const CAMERA_MAX_OFFSET = -100.0
const CAMERA_MIN_OFFSET = 90.0

var player: Player


func _process(_delta):
	if not player:
		return

	global_position = player.global_position

	var speed_factor = player._speed / player.MAX_SPEED
	var _offset = (speed_factor * (CAMERA_MAX_OFFSET - CAMERA_MIN_OFFSET)) + CAMERA_MIN_OFFSET
	if player.is_starting():
		_offset = CAMERA_MIN_OFFSET
	offset.x = lerp(offset.x, float(_offset), 0.1)

	var _zoom = clamp(player.SPEED / player._speed, CAMERA_MAX_ZOOM, CAMERA_MIN_ZOOM)
	if player.is_starting():
		_zoom = CAMERA_MIN_ZOOM
	zoom = lerp(zoom, Vector2.ONE * _zoom, 0.1)
