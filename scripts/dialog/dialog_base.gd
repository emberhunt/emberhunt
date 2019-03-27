extends Control

enum TYPE {
	TEXT,
	DECISION
}

var _type

var _started = false
var _finished = false

func get_type():
	return _type

func set_type(type):
	_type = type

		
func has_started():
	return _started

func is_finished():
	return _finished