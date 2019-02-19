extends Control


func _on_ButtonBack_pressed():
	queue_free()


func _on_ButtonMainMenu_pressed():
	get_tree().change_scene("res://scenes/MainMenu.tscn")
	# This shall get more complicated when we set up networking
