extends Node2D

var count = 0

func play(sound):
	# Check if Sound is ON
	if Global.boolSound:
		# Create an AudioStreamPlayer which will play the sound
		var scene = load("res://scenes/AudioStreamPlayer.tscn")
		var scene_instance = scene.instance()
		scene_instance.set_name("sound"+str(count))
		count += 1
		add_child(scene_instance)
		# Specify which sound to play
		scene_instance.set_stream(sound)
		# Set volume
		scene_instance.set_volume_db(8.6858896380650365530225783783321 * log(Global.Sound))
		# Start playing
		scene_instance._set_playing(true)