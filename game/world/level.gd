extends Node2D

@onready var camera: PlayerCamera = $Camera2D
@onready var player: Player = $Player
@onready var speedometer: Speedometer = $CanvasLayer/GUI/Speedometer
@onready var speed_line: Control = $CanvasLayer/GUI/Effects/SpeedLine


func _ready():
	camera.player = player


func _process(_delta):
	speedometer.tacho_max_value = player.TACHO_MAX
	speedometer.tacho_min_value = player.TACHO_MIN
	speedometer.tacho_value = player._tacho

	speedometer.thermo_max_value = player.HEAT_MAX
	speedometer.thermo_min_value = 0.0
	speedometer.thermo_value = player._heat

	speedometer.speed_value = player._speed

	speed_line.material.set_shader_parameter(
		"line_density", (player._speed / player.MAX_SPEED) * 0.5
	)
