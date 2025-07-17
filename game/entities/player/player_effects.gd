class_name PlayerEffects
extends AnimatedSprite2D

var _config = {
	fire_big =
	{
		offset = Vector2(-25, 0),
		flip_h = true,
	},
	fire_small =
	{
		offset = Vector2(-15, -17),
		flip_h = true,
	},
	boost =
	{
		offset = Vector2(12, 0),
		flip_h = false,
	},
	charge =
	{
		offset = Vector2(0, 0),
		flip_h = false,
	},
}


func _ready():
	stop_effects()


func play_effect(effect_name: String):
	if effect_name not in _config.keys():
		return

	visible = true
	play(effect_name)
	offset = _config[effect_name].offset
	flip_h = _config[effect_name].flip_h
	speed_scale = 1.0 / Engine.time_scale


func stop_effects():
	stop()
	visible = false
