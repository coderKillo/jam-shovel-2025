extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var player: Player = $Player
@onready var tacho_bar: ProgressBar = $CanvasLayer/GUI/ProgressBar


func _ready():
	pass


func _process(_delta):
	camera.global_position = player.global_position

	tacho_bar.max_value = player.TACHO_MAX
	tacho_bar.value = player._tacho
