extends "res://scripts/dialog/dialog_base.gd"


var _nextSuccess
var _nextFailure

func init(next):
	#$text.set_visible_characters(0)
	#$text.percent_visible = 0
	$text.set_bbcode("Event")
	_nextSuccess = next[0]
	_nextFailure = next[1]
	_started = false
	_finished = false

func finish():
	_finished = true

func get_next_success():
	return _nextSuccess

func get_next_failure():
	return _nextFailure
