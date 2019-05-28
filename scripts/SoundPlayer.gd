extends Node2D

var count = 0
var sound_player_scene = load("res://scenes/AudioStreamPlayer.tscn")

var load_sound_path = "res://assets/sounds/preload_sfx/"
var loaded_sounds = {}

func _ready():
	_load_sounds(load_sound_path)

func play(sound, volume=0):
	# Check if Sound is ON
	if Global.boolSound:
		# Create an AudioStreamPlayer which will play the sound
		var scene_instance = sound_player_scene.instance()
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
	
func _load_sounds(path):
	var directory = Directory.new()
	if directory.open(path) == OK:
		directory.list_dir_begin()
		var file_name = directory.get_next()
		while( file_name != ""):
			if file_name.ends_with(".wav.import"):
				loaded_sounds[file_name.trim_suffix(".wav.import")] = load(path+file_name.replace(".import",""))
			file_name = directory.get_next()
	else:
		print("Error opening "+path)