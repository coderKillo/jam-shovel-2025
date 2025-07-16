extends Node2D

@onready var camera: PlayerCamera = $Camera2D
@onready var player: Player = $Player
@onready var tacho_bar: ProgressBar = $CanvasLayer/GUI/ProgressBar
@onready var heat_bar: ProgressBar = $CanvasLayer/GUI/ProgressBar2


func _ready():
	camera.player = player


func _process(_delta):
	tacho_bar.max_value = player.TACHO_MAX
	tacho_bar.value = player._tacho

	heat_bar.max_value = player.HEAT_MAX
	heat_bar.value = player._heat
