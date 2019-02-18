extends Control

func _on_ButtonPlay_pressed():
	pass # TODO: add char creation / char select

func _on_ButtonSettings_pressed():
	get_tree().change_scene("res://scenes/Settings.tscn")

func _on_ButtonExit_pressed():
	get_tree().quit()
