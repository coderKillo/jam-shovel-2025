extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var player: Player = $Player
@onready var tacho_bar: ProgressBar = $CanvasLayer/GUI/ProgressBar
@onready var heat_bar: ProgressBar = $CanvasLayer/GUI/ProgressBar2

const CAMERA_MAX_ZOOM = 0.7
const CAMERA_MIN_ZOOM = 2.0


func _ready():
	pass


func _process(_delta):
	camera.global_position = player.global_position
	var zoom = Vector2.ONE * clamp(player.SPEED / player._speed, CAMERA_MAX_ZOOM, CAMERA_MIN_ZOOM)
	camera.zoom = lerp(camera.zoom, zoom, 0.5)

	tacho_bar.max_value = player.TACHO_MAX
	tacho_bar.value = player._tacho

	heat_bar.max_value = player.HEAT_MAX
	heat_bar.value = player._heat
