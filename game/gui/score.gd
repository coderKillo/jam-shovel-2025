extends Control

const ZOMBIE_KILL_POINTS = 100
const ZOMBIE_PER_COMBO = 4
const COMBO_TIME = 5.0

@onready var score_label: Label = %Score
@onready var combo_label: Label = %Combo
@onready var points_label: Label = %Points
@onready var combo_reset_bar: ProgressBar = %ComboResetBar

var _current_score := 0:
	set = _set_score

var _current_points := 0:
	set = _set_points

var _current_sub_combo := 0
var _current_combo := 0:
	set = _set_combo

var _combo_tween: Tween
var _combo_timer: Timer


func _ready():
	Events.enemy_killed.connect(_on_enemy_killed)
	Events.player_hit_wall.connect(_on_player_hit_wall)
	Events.engine_start_failed.connect(_on_engine_start_failed)
	Events.score_points.connect(_on_score_points)

	_combo_tween = get_tree().create_tween()
	_combo_tween.set_loops()
	_combo_tween.tween_property(combo_label, "rotation_degrees", 15.0, 1.0).from(-15.0)
	_combo_tween.tween_property(combo_label, "rotation_degrees", -15.0, 1.0).from(15.0)

	_combo_timer = Timer.new()
	_combo_timer.one_shot = true
	_combo_timer.timeout.connect(_on_combo_timer_timeout)
	add_child(_combo_timer)

	_current_score = 0
	_current_points = 0
	_current_combo = 0


func _process(_delta):
	combo_reset_bar.max_value = COMBO_TIME
	combo_reset_bar.value = _combo_timer.time_left


func _set_score(value: int):
	_current_score = value
	score_label.text = str(value)
	_bounce(score_label, 40)


func _set_points(value: int):
	var diff = value - _current_points
	_current_points = value
	points_label.text = str(value)
	points_label.visible = _current_points > 1
	if diff > 25:
		_bounce(points_label, 10)
	if _current_points > 1:
		_combo_timer.start(COMBO_TIME)


func _set_combo(value: int):
	_current_combo = value
	combo_label.text = str(value) + "x"
	combo_label.visible = _current_combo > 1
	combo_label.scale = Vector2.ONE * (1.0 + (min(_current_combo, 100.0) / 100.0 * 1.0))
	_bounce(combo_label, 20)


func _bounce(node, value):
	var tween = get_tree().create_tween()
	(
		tween
		. tween_property(node, "position:y", 0, 0.1)
		. from(-value)
		. set_trans(Tween.TRANS_BOUNCE)
		. set_ease(Tween.EASE_OUT)
	)


func _combo_break():
	_current_score += _current_combo * _current_points
	_current_combo = 0
	_current_points = 0


func _on_combo_timer_timeout():
	_combo_break()


func _on_enemy_killed():
	_current_sub_combo += 1
	if _current_sub_combo >= ZOMBIE_PER_COMBO:
		_current_combo += 1
		_current_sub_combo = 0
	_current_points += ZOMBIE_KILL_POINTS


func _on_engine_start_failed():
	_combo_break()


func _on_score_points(value):
	_current_points += value


func _on_player_hit_wall():
	_combo_break()
