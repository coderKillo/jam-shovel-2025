class_name BloodSplash
extends AnimatedSprite2D

const OFFSETS = [50, 0, 30, 30, 30, 30, 40, 40, 0]
const SIZE = 9


func _ready():
	var index = randi() % SIZE
	play("splash_%s" % index)
	offset.x = OFFSETS[index]

	await animation_finished
