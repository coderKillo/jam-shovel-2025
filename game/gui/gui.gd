class_name Gui
extends Control

@export var level_loader: LevelListLoader

@onready var speedometer: Speedometer = $Speedometer
@onready var speed_line: Control = $Effects/SpeedLine
@onready var score: Score = $Score

var player: Player


func _ready():
	level_loader.level_ready.connect(_on_level_ready)
	level_loader.level_loaded.connect(_on_level_loaded)


func _process(_delta):
	if not is_instance_valid(player):
		return

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


func _on_level_loaded():
	score.reset()


func _on_level_ready():
	player = level_loader.current_level.player
