class_name PlayerSounds
extends Node2D

@onready var sound_effects = {
	engine_on = $EnigneOnSoundEffect,
	engine_off = $EnigneOffSoundEffect,
	normal = $EnigneNormalSoundEffect,
	accelerate = $EnigneAccelerateSoundEffect,
}

var _last_sound_effect := ""


func play_sound_effect(sound_name: String):
	for id in sound_effects.keys():
		var audio_player := sound_effects[id] as AudioStreamPlayer2D
		if id == sound_name:
			if not audio_player.playing:
				audio_player.play()
				_last_sound_effect = sound_name
		else:
			audio_player.stop()


func stop_all():
	play_sound_effect("")


func update_sound(tacho, min_tach, max_tacho):
	var audio_player := sound_effects.accelerate as AudioStreamPlayer2D
	var tacho_normalized = (tacho - min_tach) / (max_tacho - min_tach)
	audio_player.pitch_scale = (tacho_normalized * (1.1 - 0.95)) + 0.95
	audio_player.volume_db = (tacho_normalized * (0 + 10)) + 0
