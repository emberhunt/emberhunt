extends TextureButton



func _on_TextureButton_pressed():
	SoundPlayer.play(preload("res://assets/sounds/click.wav"))
	var scene = preload("res://scenes/PauseMenu.tscn")
	var scene_instance = scene.instance()
	scene_instance.set_name("PauseMenu")
	get_parent().add_child(scene_instance)
