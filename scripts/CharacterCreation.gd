extends Container


func _on_ButtonBack_pressed():
	SoundPlayer.play(preload("res://assets/sounds/click.wav"))
	get_tree().change_scene("res://scenes/CharacterSelection.tscn")

func _on_ButtonFinish_pressed():
	# Register the new character
	var selectedClass = get_node("../ScrollContainer/VBoxContainer").selected
	var charData = {
		"class" : selectedClass,
		"level": 1,
		"experience" : 0,
		"max_hp" : Global.init_stats[selectedClass].max_hp,
		"max_mp" : Global.init_stats[selectedClass].max_mp,
		"strength" : Global.init_stats[selectedClass].strength,
		"agility" : Global.init_stats[selectedClass].agility,
		"magic" : Global.init_stats[selectedClass].magic,
		"luck" : Global.init_stats[selectedClass].luck,
		"physical_defense" : Global.init_stats[selectedClass].physical_defense,
		"magic_defense" : Global.init_stats[selectedClass].magic_defense,
		"inventory" : {
			"4": {"item_id":"woodsword","quantity":""}
		}
	}
	Global.charactersData[str(Global.charactersData.size())] = charData
	# Send the selected class to the server
	Networking.sendServeNewCharacterData(get_node("../ScrollContainer/VBoxContainer").selected)
	SoundPlayer.play(preload("res://assets/sounds/click.wav"))
	get_tree().change_scene("res://scenes/CharacterSelection.tscn")