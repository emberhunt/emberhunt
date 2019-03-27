extends Control


const DialogType = preload("res://scripts/dialog/dialog_base.gd")

var _index = 0
var _init = false
var _dialog

var text = "test asdf asdf asd asdf asdfe f a wfawe a"
var choices = ["first", "second", "third"]

var _conversation = []

func _ready():
	set_process_input(true)
	
	start_conversation("Manfred")
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			_handle_next_dialog()
			
func _handle_next_dialog():
			if _index > _conversation.size():
				return
			if _index == _conversation.size():
				get_dialog_type(_conversation[_index-1][0]).hide()
				stop_conversation()
	
			elif _index >= 0:
				_dialog = get_dialog_type(_conversation[_index][0])
				if not _init:
					_dialog.init(_conversation[_index][1])
					_init = true
				
				get_dialog_type(_conversation[_index-1][0]).hide()
				get_dialog_type(_conversation[_index][0]).show()
				if _conversation[_index][0] == DialogType.TYPE.TEXT:
					if _dialog.is_finished():
						_init = false
						_index += 1
						_handle_next_dialog()					
					elif _dialog.has_started():
						_dialog.finish()
						_init = false
						_index += 1
					else:
						_dialog.start()
						
				elif _conversation[_index][0] == DialogType.TYPE.DECISION:
					pass #handled by button press dialogDecision

func _on_dialogDecision_on_button_pressed(buttonId):
	_dialog.finish()
	_index += 1
	_init = false
	_handle_next_dialog()
	
func start_conversation(conversationName):
	if not Global.allDialogs.has(conversationName):
		get_node("/root/Console/console").error("Couldn't find dialog: " + conversationName)
		return
	
	var conversation : Dictionary = Global.allDialogs[conversationName]
	
	$dialogs.show()
	for i in range(conversation.size()):
		if conversation.keys()[i] == "currentBegin":
			continue
		var dialog = conversation[conversation.keys()[i]]
		match (dialog.type):
			"Text":
				_conversation.append([DialogType.TYPE.TEXT, dialog.text])
			"Event":
				pass
			"Decision":
				var choices = []
				for i in range(dialog.choices.size()):
					choices.append(dialog.choices.text)
				_conversation.append([DialogType.TYPE.DECISION, choices])
			_:
				pass


func stop_conversation():
	$dialogs.hide()

func get_dialog_type(type):
	if type == DialogType.TYPE.TEXT:
		return $dialogs.get_child(0)
	elif type == DialogType.TYPE.DECISION:
		return $dialogs.get_child(1)
