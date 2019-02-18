extends Control

func _on_ButtonPlay_pressed():
	get_tree().change_scene("res://scenes/player.tscn")

func _on_ButtonSettings_pressed():
	get_tree().change_scene("res://scenes/Settings.tscn")

func _on_ButtonExit_pressed():
	get_tree().quit()
