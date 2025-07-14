class_name Enemy
extends CharacterBody2D

const SPEED = 30.0

signal died

@onready var blood_splash_scene = preload("res://game/effects/blood/blood_splash.tscn")


func _physics_process(delta):
	velocity += get_gravity() * delta

	velocity.x = -SPEED
	move_and_slide()


func kill():
	died.emit()

	var blood_splash = blood_splash_scene.instantiate()
	get_parent().add_child(blood_splash)
	blood_splash.position = global_position

	queue_free()
