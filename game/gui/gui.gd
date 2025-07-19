class_name Gui
extends Control

@export var level_loader: LevelListLoader
@export var background_music: AudioStreamPlayer

@onready var speedometer: Speedometer = $Speedometer
@onready var speed_line: Control = $Effects/SpeedLine
@onready var score: Score = $Score
@onready var level_label: Label = $LevelLabel

var player: Player


func _ready():
	level_loader.level_ready.connect(_on_level_ready)
	level_loader.level_loaded.connect(_on_level_loaded)

	Events.tutorial_active.connect(_on_tutorial_active)


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
	background_music.play()


func _on_level_ready():
	player = level_loader.current_level.player
	level_loader.current_level.score = score
	level_label.text = "1-%s" % GameState.get_current_level()


func _on_tutorial_active(active: bool):
	if active:
		hide()
	else:
		show()
