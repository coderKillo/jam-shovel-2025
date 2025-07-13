class_name Player
extends CharacterBody2D

enum PlayerState { IDLE, ENGINE_ON, ENGINE_OFF, ENGINE_STARTED }

const JUMP_VELOCITY = -400.0

const SPEED = 300.0
const ACCELERATION = 400.0
const MAX_SPEED = 800.0

const TACHO_CHANGE_RATE = 1.0
const TACHO_MAX = 5.0

var _current_state := PlayerState.IDLE

var _heat := 0.0
var _speed := 0.0
var _tacho := 0.0


func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

	print("%s" % _current_state)

	match _current_state:
		PlayerState.IDLE:
			_current_state = PlayerState.ENGINE_OFF

		PlayerState.ENGINE_OFF:
			if Input.is_action_just_pressed("jump"):
				_speed = 0
				_current_state = PlayerState.ENGINE_STARTED
			else:
				_speed -= ACCELERATION * delta

		PlayerState.ENGINE_STARTED:
			if Input.is_action_just_pressed("jump"):
				_speed = (_tacho / TACHO_MAX) * MAX_SPEED
				_current_state = PlayerState.ENGINE_ON
			else:
				_tacho += delta * TACHO_CHANGE_RATE

		PlayerState.ENGINE_ON:
			if Input.is_action_pressed("move_right") and is_on_floor():
				_speed += ACCELERATION * delta
			else:
				_speed = lerp(_speed, SPEED, delta)

			if Input.is_action_just_pressed("jump") and is_on_floor():
				velocity.y = JUMP_VELOCITY
				_current_state = PlayerState.ENGINE_OFF

		_:
			pass

	_speed = clamp(_speed, 0, MAX_SPEED)
	velocity.x = _speed

	move_and_slide()
