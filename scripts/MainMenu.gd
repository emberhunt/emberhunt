extends Control

func _on_ButtonPlay_pressed():
	SoundPlayer.play(preload("res://assets/sounds/click.wav"))
	get_tree().change_scene("res://scenes/player.tscn")

func _on_ButtonSettings_pressed():
	SoundPlayer.play(preload("res://assets/sounds/click.wav"))
	get_tree().change_scene("res://scenes/Settings.tscn")

func _on_ButtonExit_pressed():
	SoundPlayer.play(preload("res://assets/sounds/click.wav"))
	get_tree().quit()
	
func _input(event):
	if event.is_action_pressed("ui_page_down"): # access attack creator
		get_tree().change_scene("res://dev_tools/AttackCreator.tscn")