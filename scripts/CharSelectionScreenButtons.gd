extends Container


func _on_ButtonBack_pressed():
	SoundPlayer.play(preload("res://assets/sounds/click.wav"))
	get_tree().change_scene("res://scenes/MainMenu.tscn")


func _on_ButtonPlay_pressed():
	Global.paused = false
	SoundPlayer.play(preload("res://assets/sounds/click.wav"))
	get_tree().change_scene("res://scenes/testWorld.tscn")

func _on_ButtonCreate_pressed():
	SoundPlayer.play(preload("res://assets/sounds/click.wav"))
	get_tree().change_scene("res://scenes/CharacterCreation.tscn")
