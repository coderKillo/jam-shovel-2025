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

var _combo_tween: Tween


func _ready():
	_current_score = 0
	_current_points = 0
	_current_combo = 0

	Events.enemy_killed.connect(_on_enemy_killed)
	Events.player_hit_wall.connect(_on_player_hit_wall)
	Events.engine_start_failed.connect(_on_engine_start_failed)

	_combo_tween = get_tree().create_tween()
	_combo_tween.set_loops()
	_combo_tween.tween_property(combo_label, "rotation_degrees", 15.0, 1.0).from(-15.0)
	_combo_tween.tween_property(combo_label, "rotation_degrees", -15.0, 1.0).from(15.0)


func _process(_delta):
	if Input.is_action_just_pressed("move_up"):
		_current_combo += 1
		_current_combo *= 10
	if Input.is_action_just_pressed("move_left"):
		_current_points += 1
		_current_points *= 10


func _set_score(value: int):
	_current_score = value
	score_label.text = str(value)
	_bounce(combo_label, 40)


func _set_points(value: int):
	_current_points = value
	points_label.text = str(value)
	#points_label.visible = _current_points > 1
	_bounce(combo_label, 10)


func _set_combo(value: int):
	_current_combo = value
	combo_label.text = str(value) + "x"
	#combo_label.visible = _current_combo > 1
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
	_current_score = _current_combo * _current_points
	_current_combo = 0
	_current_points = 0


func _on_enemy_killed():
	_current_combo += 1
	_current_points += ZOMBIE_KILL_POINTS


func _on_engine_start_failed():
	_combo_break()


func _on_player_hit_wall():
	_combo_break()
