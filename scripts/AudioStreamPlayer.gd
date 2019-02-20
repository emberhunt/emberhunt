extends AudioStreamPlayer

func _process(delta):
	# If finished playing delete itself
	if not is_playing():
		queue_free()
	pass