extends Control

onready var inventorySystem = get_node("../inventorySystem")


func _on_ButtonBack_pressed():
	SoundPlayer.play(preload("res://assets/sounds/click.wav"))
	if not inventorySystem.visible:
		get_node("../moveButton").disabled = false
		get_node("../shootButton").disabled = false
	Global.paused = false
	
	queue_free()


func _on_ButtonMainMenu_pressed():
	SoundPlayer.play(preload("res://assets/sounds/click.wav"))
	get_tree().change_scene("res://scenes/MainMenu.tscn")
	
	Networking.exitWorld()