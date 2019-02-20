extends Control

func _on_ButtonPlay_pressed():
	SoundPlayer.play(load("res://assets/sounds/click.wav"))
	get_tree().change_scene("res://scenes/player.tscn")

func _on_ButtonSettings_pressed():
	SoundPlayer.play(load("res://assets/sounds/click.wav"))
	get_tree().change_scene("res://scenes/Settings.tscn")

func _on_ButtonExit_pressed():
	SoundPlayer.play(load("res://assets/sounds/click.wav"))
	get_tree().quit()
