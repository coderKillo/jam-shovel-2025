class_name AudioQueueRandom
extends Node2D

@export var audio_streams: Array[AudioStreamPlayer2D]


func play_random():
	audio_streams.pick_random().play()
