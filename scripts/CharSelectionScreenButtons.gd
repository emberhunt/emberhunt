extends Container


func _on_ButtonBack_pressed():
	SoundPlayer.play(preload("res://assets/sounds/click.wav"))
	get_tree().change_scene("res://scenes/MainMenu.tscn")


func _on_ButtonPlay_pressed():
	Global.paused = false
	Global.charID = get_node("../ScrollContainer/VBoxContainer").selected
	SoundPlayer.play(preload("res://assets/sounds/click.wav"))
	Networking.requestToJoinWorld("FortressOfTheDark", Global.charID)
	# Add the player and GUI
	Global.worldReadyFunctions["FortressOfTheDark"] = funcref(get_node("/root/Global"), "spawnPlayerAndGUI")
	get_tree().change_scene("res://scenes/worlds/FortressOfTheDark.tscn")

func _on_ButtonCreate_pressed():
	SoundPlayer.play(preload("res://assets/sounds/click.wav"))
	get_tree().change_scene("res://scenes/CharacterCreation.tscn")
