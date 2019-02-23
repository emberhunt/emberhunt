extends Control


func _on_ButtonBack_pressed():
	SoundPlayer.play(preload("res://assets/sounds/click.wav"))
	get_node("../../moveButton").disabled = false
	get_node("../../shootButton").disabled = false
	get_node("../PauseButton").paused = false
	queue_free()


func _on_ButtonMainMenu_pressed():
	SoundPlayer.play(preload("res://assets/sounds/click.wav"))
	get_tree().change_scene("res://scenes/MainMenu.tscn")
	# This shall get more complicated when we set up networking
