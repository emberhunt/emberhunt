extends AudioStreamPlayer

func set_sound_volume(amount): # Convert from percentage to decibels
	return 10 * log(amount)

func _process(delta):
	# Check if the player is in correct scenes for the theme to be played
	if get_tree().get_current_scene().get_name()=="MainMenu" or get_tree().get_current_scene().get_name()=="Settings":
		if Global.boolMusic and not is_playing():
			# Music is ON in the settings and the theme is not playing
			_set_playing(true) # Start playing
		elif not Global.boolMusic and is_playing():
			# Music is OFF in the settings and the theme is playing
			_set_playing(false) # Stop playing
		# Set volume
		set_volume_db(set_sound_volume(Global.Music))
	else: # The player is not in the main menu scenes, so other themes should be played
		_set_playing(false) # Stop playing
	pass