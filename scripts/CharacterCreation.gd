extends Container

func _ready():
	# Get the character data from the server
	Networking.requestServerForMyCharacterData()

func _on_ButtonBack_pressed():
	SoundPlayer.play(preload("res://assets/sounds/click.wav"))
	get_tree().change_scene("res://scenes/CharacterSelection.tscn")

func _on_ButtonFinish_pressed():
	# Register the new character
	var charData = {"class":get_node("../ScrollContainer/VBoxContainer").selected, "level": 1}
	Global.charactersData[str(Global.charactersData.size())] = charData
	# Send the selected class to the server
	Networking.sendServeNewCharacterData(get_node("../ScrollContainer/VBoxContainer").selected)
	SoundPlayer.play(preload("res://assets/sounds/click.wav"))
	get_tree().change_scene("res://scenes/CharacterSelection.tscn")
