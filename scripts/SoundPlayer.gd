extends Node2D

var count = 0

func play(sound, volume=0):
	# Check if Sound is ON
	if Global.boolSound:
		# Create an AudioStreamPlayer which will play the sound
		var scene = load("res://scenes/AudioStreamPlayer.tscn")
		var scene_instance = scene.instance()
		count += 1
		scene_instance.set_name("sound"+str(count))
		add_child(scene_instance)
		# Specify which sound to play
		scene_instance.set_stream(sound)
		# Set volume
		scene_instance.set_volume_db((10 * log(Global.Sound))+volume)
		# Start playing
		scene_instance._set_playing(true)
		return "sound"+str(count)
	return false