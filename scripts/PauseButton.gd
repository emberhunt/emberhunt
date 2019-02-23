extends TextureButton

var paused = false

func _on_PauseButton_pressed():
	if not paused:
		paused = true
		SoundPlayer.play(preload("res://assets/sounds/click.wav"))
		var scene = preload("res://scenes/PauseMenu.tscn")
		var scene_instance = scene.instance()
		scene_instance.set_name("PauseMenu")
		get_parent().add_child(scene_instance)
		# Disable touchpads
		get_node("../../moveButton").disabled = true
		get_node("../../shootButton").disabled = true