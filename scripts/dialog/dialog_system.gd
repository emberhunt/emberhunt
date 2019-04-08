extends Control


const DialogType = preload("res://scripts/dialog/dialog_base.gd")

var _lastIndex
var _index

var _conversationStarted = false
var _init = false # single dialog box init
var _dialog

var _dialogPartner

var _conversation = {}

func _ready():
	show()
	# hide children
	for i in range($dialogs.get_child_count()):
		$dialogs.get_child(i).hide()
	
	set_process_input(true)
	
func _input(event):
	if not _conversationStarted:
		return
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			_handle_next_dialog()
			
func _handle_next_dialog():
	if _conversation[_index][0] == DialogType.TYPE.END:
		get_dialog_type(_conversation[_index][0]).hide()
		stop_conversation()
	else:
		_dialog = get_dialog_type(_conversation[_index][0])
		
		if not _init:
			_dialog.init(_conversation[_index][1])
			_init = true

		get_dialog_type(_conversation[_lastIndex][0]).hide()
		get_dialog_type(_conversation[_index][0]).show()
		if _conversation[_index][0] == DialogType.TYPE.TEXT:
			if _dialog.is_finished():
				_init = false
				_lastIndex = _index
				_index = _dialog.get_next()
				_handle_next_dialog()
				_dialog.finish()
			elif _dialog.has_started():
				_init = false
				_lastIndex = _index
				_index = _dialog.get_next()
			else:
				_dialog.start()

		elif _conversation[_index][0] == DialogType.TYPE.DECISION:
			pass #handled by button press dialogDecision
			
		elif _conversation[_index][0] == DialogType.TYPE.ENTRY:
			_init = false
			_lastIndex = _index
			_index = _dialog.get_next()
			_handle_next_dialog()					
			
		elif _conversation[_index][0] == DialogType.TYPE.EVENT:
			_init = false
			_lastIndex = _index
			_index = _dialog.get_next_success()
			#_index = _dialog.get_next_failure()
					

func _on_dialogDecision_on_button_pressed(buttonId):
	_dialog.finish()
	_lastIndex = _index
	_index = _dialog.get_next(buttonId)
	_init = false
	_handle_next_dialog()

func start_conversation(conversationName, partner):
	if _conversationStarted:
		return
	
	if not Global.allDialogs.has(conversationName):
		DebugConsole.error("Couldn't find dialog: " + conversationName)
		return
	_dialogPartner = partner
	_conversationStarted = true
	var conversation : Dictionary = Global.allDialogs[conversationName]

	$dialogs.show()
	for i in range(conversation.size()):
		if conversation.keys()[i] == "currentBegin":
			_index = conversation["currentBegin"]
			_lastIndex = _index
			continue
		
		var dialog = conversation[conversation.keys()[i]]
		match (dialog.type):
			"Text":
				var speaker = dialog.speaker
				if dialog.speaker == "{partner}":
					speaker = _dialogPartner
				elif dialog.speaker == "{player}":
					speaker = "You"
					
				_conversation[conversation.keys()[i]] = [DialogType.TYPE.TEXT, [dialog.next, dialog.text, speaker]]
			"Entry Point":
				_conversation[conversation.keys()[i]] = [DialogType.TYPE.ENTRY, dialog.next]
			"End":
				_conversation[conversation.keys()[i]] = [DialogType.TYPE.END, []]
			"Event":
				var next = []
				next.append(dialog.next_success)
				next.append(dialog.next_failure)
				_conversation[conversation.keys()[i]] = [DialogType.TYPE.EVENT, next]
			"Decision":
				var choices = []
				for i in range(dialog.choices.size()):
					var choice = dialog.choices[dialog.choices.keys()[i]]
					choices.append([choice.next, choice.text])
				_conversation[conversation.keys()[i]] = [DialogType.TYPE.DECISION, choices]
			_:
				pass
	_handle_next_dialog()

func stop_conversation():
	$dialogs.hide()
	_conversationStarted = false

func get_dialog_type(type):
	if type == DialogType.TYPE.TEXT:
		return $dialogs.get_child(0)
	elif type == DialogType.TYPE.DECISION:
		return $dialogs.get_child(1)
	elif type == DialogType.TYPE.EVENT:
		return $dialogs.get_child(2)
	elif type == DialogType.TYPE.ENTRY:
		return $dialogs.get_child(3)
	elif type == DialogType.TYPE.END:
		return $dialogs.get_child(4)
