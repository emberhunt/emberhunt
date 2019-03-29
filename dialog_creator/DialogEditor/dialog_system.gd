extends Control

class_name DialogSystem



var _currentDialog = null


func _ready():
	pass


func _load_all_dialogs(filePath : String):
	var file = File.new()
	
	file.open(filePath, fileREAD)
	
	






