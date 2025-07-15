class_name Player
extends CharacterBody2D

enum PlayerState { IDLE, ENGINE_ON, ENGINE_OFF, ENGINE_STARTED, OVERHEAT }

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var particales: GPUParticles2D = $Particales
@onready var hitbox: Area2D = $Hitbox

const JUMP_VELOCITY = -400.0

const SPEED = 300.0
const ACCELERATION = 400.0
const DEACCELERATION = 400.0
const MAX_SPEED = 800.0

const TACHO_CHANGE_RATE = 10.0
const TACHO_MAX = 5.0

const HEAT_BUILD_BOOST = 30.0
const HEAT_BUILD_NORMAL = 10.0
const HEAT_BUILD_KILL = 5.0
const HEAT_MAX = 100.0
const HEAT_RESET_PERCENT = 25.0

var _current_state := PlayerState.IDLE
var _current_tacho_change_rate := TACHO_CHANGE_RATE

var _heat := 0.0:
	set = _set_heat

var _tacho := 0.0:
	set = _set_tacho

var _speed := 0.0


func _ready():
	hitbox.body_entered.connect(_on_hitbox_hit)


func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

	_speed = velocity.x

	_update_animation()
	_update_particles()

	match _current_state:
		PlayerState.IDLE:
			_init_player()

		PlayerState.ENGINE_OFF:
			if Input.is_action_just_pressed("jump"):
				_start_engine(delta)
			else:
				_break(delta)

		PlayerState.ENGINE_STARTED:
			if Input.is_action_just_pressed("jump"):
				_launch(delta)
			elif _tacho < 0.0:
				_launch(delta)
				_launch_failed()
			else:
				_starting(delta)

		PlayerState.ENGINE_ON:
			if Input.is_action_pressed("move_right") and is_on_floor():
				_move_normal(delta)
			else:
				_move_boost(delta)

			if Input.is_action_just_pressed("jump") and is_on_floor():
				_jump(delta)

		PlayerState.OVERHEAT:
			_overheat(delta)
		_:
			pass

	_speed = clamp(_speed, 0, MAX_SPEED)
	velocity.x = _speed

	move_and_slide()

	## Handle Player State


func _init_player():
	_current_state = PlayerState.ENGINE_OFF


func _start_engine(_delta):
	_tacho = 0.0
	_current_tacho_change_rate = TACHO_CHANGE_RATE
	_current_state = PlayerState.ENGINE_STARTED


func _break(delta):
	_speed -= DEACCELERATION * delta


func _launch(_delta):
	_tacho = clamp(_tacho, 0.0, TACHO_MAX)
	_speed = (_tacho / TACHO_MAX) * MAX_SPEED
	_heat = _heat * (HEAT_RESET_PERCENT / 100)
	_current_state = PlayerState.ENGINE_ON
	Engine.time_scale = 1.0


func _launch_failed():
	Events.engine_start_failed.emit()


func _starting(delta):
	_tacho += delta * _current_tacho_change_rate
	Engine.time_scale = 0.6


func _move_normal(delta):
	_speed += ACCELERATION * delta
	if _speed > 10.0:
		_heat += HEAT_BUILD_BOOST * delta


func _move_boost(delta):
	_heat += HEAT_BUILD_NORMAL * delta
	_speed = lerp(_speed, SPEED, delta)


func _jump(_delta):
	velocity.y = JUMP_VELOCITY
	_current_state = PlayerState.ENGINE_OFF


func _overheat(_delta):
	print("LOSE!!!")

	## end Handle Player State


func _set_tacho(value):
	_tacho = value
	if _tacho > TACHO_MAX:
		_current_tacho_change_rate = -TACHO_CHANGE_RATE


func _set_heat(value):
	_heat = value
	if _heat > HEAT_MAX:
		_current_state = PlayerState.OVERHEAT
	return _heat


func _update_animation():
	if not is_on_floor() and _current_state == PlayerState.ENGINE_OFF:
		animation.rotation_degrees = -40
	else:
		animation.rotation_degrees = 0

	if _current_state == PlayerState.ENGINE_ON:
		animation.play("on")
	if _current_state == PlayerState.ENGINE_OFF:
		animation.play("off")


func _update_particles():
	if _speed < (SPEED / 10.0) or not is_on_floor():
		particales.emitting = false
	else:
		particales.emitting = true
		particales.process_material.initial_velocity_max = _speed * 1.3
		particales.process_material.initial_velocity_min = _speed * 0.7


func _on_hitbox_hit(body):
	var enemy := body as Enemy
	if not enemy:
		return

	enemy.kill()
