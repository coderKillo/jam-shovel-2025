extends Node2D

signal level_won
signal level_lost

@onready var camera: PlayerCamera = $Camera2D
@onready var player: Player = $Player
@onready var level_complete_area: Area2D = $LevelCompleteArea

var level_state: LevelState
var score: Score


func _ready():
	camera.player = player
	level_state = GameState.get_level_state(scene_file_path)
	if not level_state.tutorial_read:
		open_tutorials()

	player.overheat.connect(_on_player_overheat)
	level_complete_area.body_entered.connect(_on_level_complete)


func _on_player_overheat():
	level_lost.emit()


func _on_level_complete(_body):
	# run level without UI
	if not is_instance_valid(score):
		get_tree().quit()
		return

	var score_value = score.get_score()
	level_state.score = score_value
	if level_state.score > level_state.highscore:
		level_state.highscore = score_value

	GlobalState.save()

	level_won.emit()


func open_tutorials() -> void:
	%TutorialManager.open_tutorials()
