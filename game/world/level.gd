extends Node2D

signal level_won
signal level_lost

@onready var camera: PlayerCamera = $Camera2D
@onready var player: Player = $Player


func _ready():
	camera.player = player

	player.overheat.connect(_on_player_overheat)


func _on_player_overheat():
	level_lost.emit()
