class_name PlayerCamera
extends Camera2D

const CAMERA_MAX_ZOOM = 0.66
const CAMERA_MIN_ZOOM = 2.0
const CAMERA_MAX_OFFSET = -100.0
const CAMERA_MIN_OFFSET = 90.0

const CAMERA_SHAKE_MAX_OFFSET = 40.0
const CAMERA_SHAKE_MAX_ROLL = 10.0
const CAMERA_SHAKE_MAX_STRESS = 1.0
const CAMERA_SHAKE_MIN_STRESS = 0.1
const CAMERA_SHAKE_REDUCTION = 2.5

@export_range(0.0, 1.0) var stress: float = 0.0

var player: Player

var _freeze_timer: Timer


func _ready():
	Events.camera_freez_frame.connect(_on_frame_freeze)
	Events.camera_shake.connect(_on_camera_shake)

	_freeze_timer = Timer.new()
	_freeze_timer.one_shot = true
	add_child(_freeze_timer)


func _process(_delta):
	if not player:
		return

	_process_shake(0.0, _delta)

	global_position = player.global_position

	var speed_factor = player._speed / player.MAX_SPEED
	var _offset = (speed_factor * (CAMERA_MAX_OFFSET - CAMERA_MIN_OFFSET)) + CAMERA_MIN_OFFSET
	if player.is_starting():
		_offset = CAMERA_MIN_OFFSET
	if player.is_launching():
		_offset = CAMERA_MAX_OFFSET
	offset.x = lerp(offset.x, float(_offset), 0.1)

	var _zoom = (speed_factor * (CAMERA_MAX_ZOOM - CAMERA_MIN_ZOOM)) + CAMERA_MIN_ZOOM
	if player.is_starting():
		_zoom = CAMERA_MIN_ZOOM
	zoom = lerp(zoom, Vector2.ONE * _zoom, 0.1)


func _process_shake(angle, delta) -> void:
	var stress_speed = player._speed / player.MAX_SPEED
	var shake = pow(stress * stress_speed, 2.0)

	rotation_degrees = angle + (CAMERA_SHAKE_MAX_ROLL * shake * _get_noise(randi(), delta))
	offset.y = (CAMERA_MAX_OFFSET * shake * _get_noise(randi(), delta + 2.0))

	stress -= (CAMERA_SHAKE_REDUCTION / 100.0)
	stress = clamp(stress, CAMERA_SHAKE_MIN_STRESS, CAMERA_SHAKE_MAX_STRESS)


func _on_camera_shake(intensity: float):
	stress = clamp(intensity, CAMERA_SHAKE_MIN_STRESS, CAMERA_SHAKE_MAX_STRESS)


func _get_noise(noise_seed, time) -> float:
	var n := FastNoiseLite.new()

	n.seed = noise_seed
	n.noise_type = FastNoiseLite.TYPE_SIMPLEX
	n.frequency = 2.0

	return n.get_noise_1d(time)


func _on_frame_freeze() -> void:
	if _freeze_timer.time_left > 0.0:
		return

	var freeze_duration := 0.2
	var freeze_time_scale := 0.05

	Engine.time_scale = freeze_time_scale

	_freeze_timer.start(freeze_duration * freeze_time_scale)
	await _freeze_timer.timeout

	Engine.time_scale = 1.0
