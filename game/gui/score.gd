extends Control

const ZOMBIE_KILL_POINTS = 100

@onready var score_label: Label = %Score
@onready var combo_label: Label = %Combo
@onready var points_label: Label = %Points

var _current_score := 0:
	set = _set_score

var _current_points := 0:
	set = _set_points

var _current_combo := 0:
	set = _set_combo


func _ready():
	_current_score = 0
	_current_points = 0
	_current_combo = 0

	Events.enemy_killed.connect(_on_enemy_killed)
	Events.engine_start_failed.connect(_on_engine_start_failed)


func _set_score(value: int):
	_current_score = value
	score_label.text = str(value)


func _set_points(value: int):
	_current_points = value
	points_label.text = str(value)
	points_label.visible = _current_points > 1


func _set_combo(value: int):
	_current_combo = value
	combo_label.text = str(value) + "x"
	combo_label.visible = _current_combo > 1


func _combo_break():
	_current_score = _current_combo * _current_points
	_current_combo = 0
	_current_points = 0


func _on_enemy_killed():
	_current_combo += 1
	_current_points += ZOMBIE_KILL_POINTS


func _on_engine_start_failed():
	_combo_break()
