extends "res://scripts/dialog/dialog_base.gd"



var _nextSuccess
var _nextFailure

var _eventType
var _params

func init(next):
	#$text.set_visible_characters(0)
	#$text.percent_visible = 0
	_nextSuccess = next[0]
	_nextFailure = next[1]
	set_Event(next[2], next[3])
	_started = false
	_finished = false

func set_Event(text, params):
	_eventType = text
	$text.set_bbcode(_replace_event_text(text, params))

func execute_event():
	# ToDo:
	# - add all events
	# - create file for events or in networking
	match(_eventType):
		"Add Stats":
			DebugConsole.write_line(_replace_params("/addStat {0} {1}", _params))
#		"Take Item":
#			DebugConsole.write_line(_replace_params("/addStat {1} {0}", _params))
#		"Add Item":
#			DebugConsole.write_line(_replace_params("/addStat {1} {0}", _params))
#		"Fail Quest":
#			DebugConsole.write_line(_replace_params("/addStat {1} {0}", _params))
#		"Accept Quest":
#			DebugConsole.write_line(_replace_params("/addStat {1} {0}", _params))
		_:
			DebugConsole.error("Couldn't find event text: " + _eventType)

func _replace_event_text(text : String, params : Dictionary) -> String:
	var arr = []
	for i in range(params.size()):
		var val = params[params.keys()[i]]
		arr.append(val)
	_params = arr
	_eventType = text
	match(text):
		"Add Stats":
			return _replace_params("Added {1} {0}!", arr)
		"Take Item":
			return _replace_params("Took {1} {0}!", arr)
		"Add Item":
			return _replace_params("Added {1} {0}!", arr)
		"Fail Quest":
			return _replace_params("Failed Quest {0}!", arr)
		"Accept Quest":
			return _replace_params("Accepted Quest {0}!", arr)
		_:
			DebugConsole.error("Couldn't find event text: " + text)
			return ""

func _replace_params(text : String, params : Array) -> String:
	for i in range(params.size()):
		text = text.replace("{" + str(i) + "}", params[i])
	return text

func finish():
	_finished = true

func get_next_success():
	return _nextSuccess

func get_next_failure():
	return _nextFailure
