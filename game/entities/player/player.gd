class_name Player
extends CharacterBody2D

signal overheat

enum PlayerState { IDLE, ENGINE_ON, ENGINE_OFF, LAUNCHING, ENGINE_STARTED, OVERHEAT }

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var particales: GPUParticles2D = $Particales
@onready var hitbox: Area2D = $Hitbox
@onready var wall_hitbox: Area2D = $WallHitbox
@onready var sound: PlayerSounds = $PlayerSounds
@onready var effects: PlayerEffects = $PlayerEffects

const JUMP_VELOCITY = -500.0

const SPEED = 200.0
const MAX_SPEED = 800.0

const TACHO_MAX = 1.0
const TACHO_MIN = 0.0
const TACHO_THRESHOLD_HEAT = 0.75
const TACHO_THRESHOLD_COOL = 0.5
const TACHO_ACCELERATION = 1.5
const TACHO_DEACCELERATION = 1.0

const HEAT_BUILD_STARTING = 100.0
const HEAT_BUILD_HIGH_TACHO = 30.0
const HEAT_BUILD_KILL = 0.0
const HEAT_RELEASE_IN_AIR = 80.0
const HEAT_RELEASE_LOW_TACHO = 30.0
const HEAT_MAX = 100.0
const HEAT_RESET_PERCENT = 25.0
const HEAT_HOT_TRESHHOLD = HEAT_MAX * 0.75

const LAUNCH_TIME = 0.3

const SLOWMOTION_FACTOR = 0.3

var _current_state := PlayerState.IDLE
var _acceleration := false
var _launch_timer := LAUNCH_TIME

var _heat := 0.0:
	set = _set_heat

var _tacho := 0.0:
	set = _set_tacho

var _speed := 0.0


func _ready():
	hitbox.body_entered.connect(_on_hitbox_hit)
	wall_hitbox.body_entered.connect(_on_wall_hitbox_hit)


func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

	_speed = velocity.x
	_acceleration = false

	_update_animation()
	sound.update_sound(_tacho, TACHO_MIN, TACHO_MAX)
	_update_particles()
	_update_score()

	match _current_state:
		PlayerState.IDLE:
			_init_player()

		PlayerState.ENGINE_OFF:
			if Input.is_action_just_pressed("move_right"):
				_start_engine(delta)
			elif is_on_floor():
				_break(delta)

		PlayerState.ENGINE_STARTED:
			if Input.is_action_just_released("move_right"):
				_start_launch(delta)
			else:
				_starting(delta)

		PlayerState.LAUNCHING:
			if _launch_timer < 0:
				_engine_on(delta)
			else:
				_launching(delta)

		PlayerState.ENGINE_ON:
			if Input.is_action_pressed("move_right") and is_on_floor():
				_move_boost(delta)
			else:
				_move_normal(delta)

			if Input.is_action_just_pressed("jump") and is_on_floor():
				_jump(delta)

		PlayerState.OVERHEAT:
			_overheat(delta)
		_:
			pass

	_update_heat(delta)
	_update_speed(delta)

	_speed = clamp(_speed, 0, MAX_SPEED)
	velocity.x = _speed

	move_and_slide()

	## Handle Player State


func is_starting():
	return _current_state == PlayerState.ENGINE_STARTED


func is_launching():
	return _current_state == PlayerState.LAUNCHING


func _init_player():
	_tacho = 0
	_heat = 0
	_current_state = PlayerState.ENGINE_OFF


func _start_engine(_delta):
	_current_state = PlayerState.ENGINE_STARTED
	Engine.time_scale = SLOWMOTION_FACTOR
	sound.play_sound_effect("engine_on")


func _break(delta):
	_tacho -= TACHO_DEACCELERATION * delta
	sound.stop_all()


func _start_launch(_delta):
	Engine.time_scale = 1.0
	_current_state = PlayerState.LAUNCHING
	_launch_timer = LAUNCH_TIME
	Events.camera_shake.emit(0.8 * (_tacho / TACHO_MAX))
	sound.play_sound_effect("accelerate")


func _launching(delta):
	velocity.y = 0
	_launch_timer -= delta
	effects.play_effect("boost")


func _engine_on(_delta):
	_current_state = PlayerState.ENGINE_ON


func _launch_failed():
	Events.engine_start_failed.emit()


func _starting(delta):
	_tacho += (TACHO_ACCELERATION / SLOWMOTION_FACTOR) * delta
	effects.play_effect("charge")


func _move_normal(delta):
	var new_speed = lerp(_speed, SPEED, delta)
	_tacho = (new_speed / MAX_SPEED) * TACHO_MAX
	sound.play_sound_effect("normal")
	if _heat > HEAT_HOT_TRESHHOLD:
		effects.play_effect("fire_small")
	else:
		effects.stop_effects()


func _move_boost(delta):
	_tacho += TACHO_ACCELERATION * delta
	sound.play_sound_effect("accelerate")
	if _heat > HEAT_HOT_TRESHHOLD:
		effects.play_effect("fire_big")
	else:
		effects.stop_effects()


func _jump(_delta):
	velocity.y = JUMP_VELOCITY
	_current_state = PlayerState.ENGINE_OFF
	sound.play_sound_effect("engine_off")


func _overheat(_delta):
	Engine.time_scale = 1.0
	overheat.emit()
	set_process(false)
	set_physics_process(false)

	## end Handle Player State


func _set_tacho(value):
	_acceleration = value > _tacho
	_tacho = clamp(value, TACHO_MIN, TACHO_MAX)


func _set_heat(value):
	_heat = clamp(value, 0, HEAT_MAX)
	if _heat >= HEAT_MAX:
		_current_state = PlayerState.OVERHEAT
	return _heat


func _update_heat(delta):
	if _tacho > TACHO_THRESHOLD_HEAT:
		if _current_state == PlayerState.ENGINE_STARTED:
			_heat += HEAT_BUILD_STARTING * delta / SLOWMOTION_FACTOR
		elif _acceleration:
			_heat += HEAT_BUILD_HIGH_TACHO * delta
	elif _tacho < TACHO_THRESHOLD_COOL:
		_heat -= HEAT_RELEASE_LOW_TACHO * delta

	if _current_state == PlayerState.ENGINE_OFF and not is_on_floor():
		_heat -= HEAT_RELEASE_IN_AIR * delta


func _update_speed(_delta):
	if _current_state == PlayerState.ENGINE_STARTED:
		return
	_speed = (_tacho / TACHO_MAX) * MAX_SPEED


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


func _update_score():
	if hitbox.has_overlapping_bodies():
		Events.score_points.emit(2)


func _on_hitbox_hit(body):
	var enemy := body as Enemy
	if not enemy:
		return

	_heat += HEAT_BUILD_KILL
	enemy.kill()

	Events.score_points.emit(_tacho * 100)
	Events.camera_freez_frame.emit()
	Events.camera_shake.emit(0.4)


func _on_wall_hitbox_hit(_body):
	Events.player_hit_wall.emit()
