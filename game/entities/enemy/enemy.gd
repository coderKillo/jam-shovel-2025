class_name Enemy
extends CharacterBody2D

const SPEED = 30.0
const VARIANTS = 4

const ACTIONS = [
	"attack1",
	"attack2",
	"scream",
]

const DEATHS = [
	"death1",
	"death2",
	"death3",
	"death4",
]

signal died

@onready var blood_splash_scene = preload("res://game/effects/blood/blood_splash.tscn")
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

var _varient = 0
var _action_running := false
var _speed = 0
var _direction = -1


func _ready():
	_varient = randi_range(1, VARIANTS)
	animation.animation_looped.connect(_on_animation_looped)


func _physics_process(delta):
	velocity += get_gravity() * delta

	velocity.x = _direction * _speed
	move_and_slide()

	if not _action_running:
		_action_running = true
		_update_animation()


func _update_animation():
	animation.flip_h = _direction == -1

	if (randi() % 100) <= 50:
		var action = ACTIONS.pick_random()
		_play_animation(action)
		_speed = 0
		_direction = [1, -1].pick_random()
	else:
		_play_animation("walk")
		_speed = SPEED


func _play_animation(animation_name: String):
	animation.play("%s_%s" % [animation_name, _varient])


func _on_animation_looped():
	_action_running = false


func kill():
	died.emit()
	Events.enemy_killed.emit()

	var blood_splash = blood_splash_scene.instantiate()
	get_parent().add_child(blood_splash)
	blood_splash.position = global_position

	set_physics_process(false)
	_play_animation(DEATHS.pick_random())
	await animation.animation_looped

	queue_free()
