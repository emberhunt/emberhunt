extends Node2D

func play(sound):
	get_node("AudioStreamPlayer").set_stream(sound)
	get_node("AudioStreamPlayer")._set_playing(true)
	pass