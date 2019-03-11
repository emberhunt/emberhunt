class_name ConsoleUser


const ConsoleRights = preload("res://console/console_rights.gd")


var _name := ""
var _rights : ConsoleRights


func _init(name : String, rights = ConsoleRights.CallRights.USER):
	_name = name
	_rights = ConsoleRights.new()
	_rights.set_rights(rights)


func set_rights(rights):
	_rights.set_rights(rights)


func get_rights():
	return _rights.get_rights()


func set_name(name : String):
	_name = name
	

func get_name() -> String:
	return _name
