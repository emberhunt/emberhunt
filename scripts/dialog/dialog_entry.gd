extends "res://scripts/dialog/dialog_base.gd"


var _next

func init(next):
	_next = next

func get_next():
	return _next