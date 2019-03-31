extends Control


# prefabs
const textPrefab = preload("Nodes/graph_node_text.tscn")
const eventPrefab = preload("Nodes/graph_node_event.tscn")
const decisionPrefab = preload("Nodes/graph_node_decision.tscn")
const endPrefab = preload("Nodes/graph_node_end.tscn")
const startPrefab = preload("Nodes/graph_node_start.tscn")

# data from files
export(String, FILE) var npcFile
export(String, FILE) var playerStatsFile
export(String, FILE) var itemsFile
export(String, FILE) var animationsFile
export(String, FILE) var questFile

onready var popup : Popup = get_node("menuButton").get_popup()
onready var dialogSelector : Popup = get_node("loadedDialogsSelection").get_popup()
onready var graphEdit : GraphEdit = get_node("graphEdit")

var npcData = []
var playerStats = []
var itemsData = []
var animations = []
var questData = []

# used when loading
#var _allDialogs = {}
var _allConnections = []

var _selected = null
var _lastFile = ""
var _loadMode = false

var _entryAmount = 1

var nodeSpawn = Vector2(90.0, 90.0)
var nodesIndex = 0
var connections = []

# new
var _loadedDialogs

var _nodeIds = 0
var _entryIds = 0
var _allNodes = {}


func _ready():
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_DISABLED,SceneTree.STRETCH_ASPECT_EXPAND, Vector2(0,0))
	set_process_input(true)
	popup.connect("id_pressed", self, "_on_item_pressed")
	dialogSelector.connect("id_pressed", self, "_on_loadedDialogsSelection_item_selected")
	_load_data()
	

func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE): 
		$fileDialog.hide()
		$saveFileDialog.hide()
		
func _load_data():
	# NPC speaker (names)
	var file = File.new()
	file.open(npcFile, file.READ)
	var text = file.get_as_text()
	var fileContent = parse_json(text)
	file.close()
	
	for i in range(fileContent.size()):
		npcData.append(fileContent[fileContent.keys()[i]].name)
	
	# item names
	var itemFile = File.new()
	itemFile.open(itemsFile, itemFile.READ)
	var itemText = itemFile.get_as_text()
	var itemFileContent = parse_json(itemText)
	itemFile.close()
	
	for i in range(itemFileContent.size()):
		itemsData.append(itemFileContent[itemFileContent.keys()[i]].name)
	
	# player stats
	var statsFile = File.new()
	statsFile.open(playerStatsFile, statsFile.READ)
	var playerText = statsFile.get_as_text()
	var playerFileContent = parse_json(playerText)
	statsFile.close()
	
	for i in range(playerFileContent.size()):
		playerStats.append(playerFileContent.keys()[i])
		
	# quests
	var questsFile = File.new()
	questsFile.open(questFile, questsFile.READ)
	var questText = questsFile.get_as_text()
	var questFileContent = parse_json(questText)
	questsFile.close()
	
	for i in range(questFileContent.size()):
		questData.append(questFileContent[questFileContent.keys()[i]].name)
		

func _on_item_pressed(id):
	_create_node(popup.get_item_text(id))

func _create_node(type, position = $graphEdit.scroll_offset + Vector2(OS.get_window_size().x / 2.8,OS.get_window_size().y / 2), values = {}):
	var prefab
	
	if not values.empty():
		if int(values["nodesIndex"]) > nodesIndex:
			nodesIndex = int(values["nodesIndex"])
	
	match (type):
		"Text":
			prefab = textPrefab.instance()
			prefab.set_speaker_suggestions(npcData)
			if not values.empty():
				prefab.set_speaker(values.speaker)
				prefab.set_text(values.text)
				
		"Decision":
			prefab = decisionPrefab.instance()
			if not values.empty():
				prefab.set_text(values.text)
				for i in range(values.choices.size()):
					var next = values.choices[str(i)].next
					var text = values.choices[str(i)].text
					prefab.add_choice(i, text, next)
					_allConnections.append([str(values["nodesIndex"]), i, values.choices[str(i)].next, 0])
					
		"Event":
			prefab = eventPrefab.instance()
			prefab.set_item_suggestions("Add Item", itemsData, 1)
			prefab.set_item_suggestions("Take Item", itemsData, 1)
			prefab.set_item_suggestions("Offer Quest", questData)
			prefab.set_item_suggestions("Fail Quest", questData)
			prefab.set_item_suggestions("Set Stats", playerStats, 1)
			prefab.set_item_suggestions("Add Stats", playerStats, 1)
			
			var entries = []
			for i in range($startNode.get_popup().get_item_count()):
				entries.append($startNode.get_popup().get_item_text(i))
			prefab.set_item_suggestions("Set Entry", entries)
			if not values.empty():
				prefab.set_selected_item(values.event_type, values)
				_allConnections.append([str(values["nodesIndex"]), 0, values.next_success, 0])
				_allConnections.append([str(values["nodesIndex"]), 1, values.next_failure, 0])
			
		"End":
			prefab = endPrefab.instance()
			
		"Entry Point":
			prefab = startPrefab.instance()
			
			if $startNode.disabled:
				$startNode.disabled = false
			
			if not values.empty():
				prefab.set_entry_point(values.entry)
				$startNode.add_item(str(values.entry))
				if _entryIds <= int(values.entry):
					_entryIds = int(values.entry) + 1
					
			else:
				prefab.set_entry_point(_entryIds)
				$startNode.add_item(str(_entryIds))
				_entryIds += 1
		_:
			printerr("not recognized dialog type!")
	
	if not values.empty():
		prefab.name = str(values["nodesIndex"])
	else:
		prefab.name = str(_nodeIds)
		_nodeIds += 1
	
	prefab.offset = position
	prefab.set_type(type)

	if not values.empty():
		if _nodeIds <= int(values["nodesIndex"]):
			_nodeIds = int(values["nodesIndex"]) + 1
	
	graphEdit.add_child(prefab)
	_allNodes[prefab.name] = prefab

	if type == "Entry Point":
		for i in range($graphEdit.get_child_count()):
			var child = $graphEdit.get_child(i)
			if child.get_class() == "GraphNode" and child.get_type() == "Event":
				var entries = []
				for i in range($startNode.get_popup().get_item_count()):
					entries.append($startNode.get_popup().get_item_text(i))
				child.clear_item_suggestions("Set Entry")
				child.set_item_suggestions("Set Entry", entries)
				if child.get_selected_key() == "Set Entry":
					child.set_selected("Set Entry")
				
func _on_graphNodeText_close_request():
#	print("close")
	pass

func _on_graphNodeText_raise_request():
#	print("raise")
	pass


func _on_graphNodeText_dragged(from, to):
#	print("fromto")
#	print(from)
#	print(to)
	pass

func _on_graphEdit_connection_request(from, from_slot, to, to_slot):
	$graphEdit.connect_node(from, from_slot, to, to_slot)

func _on_graphEdit_connection_to_empty(from, from_slot, release_position):
#	print("empty")
	pass

func _on_graphEdit_disconnection_request(from, from_slot, to, to_slot):
	for i in range(_allConnections.size()):
		var con = _allConnections[i]
		if con[0] == str(from) and con[1] == from_slot and con[2] == str(to) and con[3] == to_slot:
			_allConnections.remove(i)
			
			for i in range(_allNodes.size()):
				if _allNodes[_allNodes.keys()[i]].name == from:
					# TODO add function to give node name and slot to remove connection
					_allNodes[_allNodes.keys()[i]].next = ""
			
			break
		#_allConnections.append([str(c-1), 0, dial.next, 0])
	$graphEdit.disconnect_node(from, from_slot, to, to_slot)

func _on_graphEdit_delete_nodes_request():
	print("delete")

func _on_graphEdit_duplicate_nodes_request():
#	if _selected != null:
#		if _selected.title == "Start Node":
#			return
#		var newNode = _selected.duplicate()
#		newNode.offset += Vector2(25.0, 25.0)
#		newNode.name += str(nodesIndex)
#		graphEdit.add_child(newNode)
#		nodesIndex += 1
	pass

func _on_graphEdit_node_selected(node):
	_selected = node

func _on_save_pressed():
	# file dialog 
	_loadMode = false
	$saveFileDialog.show()
	$saveFileDialog.set_current_dir($fileDialog.get_current_dir())

func _on_load_pressed():
	# file dialog 
	_loadMode = true
	$fileDialog.show()
	$fileDialog.set_current_dir($fileDialog.get_current_dir())

func _on_saveFileDialog_file_selected(filePath):
	_lastFile = filePath
	#print(_lastFile)	
	
	if $graphEdit.get_child_count() <= 2:
		return
	
	# load current file
	var file = File.new()
	file.open(filePath, file.READ)
	var text = file.get_as_text()
	var fileContent = parse_json(text)
	file.close()
	
	var dialogData = fileContent
	
	var currentBegin = ""
	
	var newConversation = {}
	#print("nodes = " + str($graphEdit.get_child_count() - 2))
	for i in range($graphEdit.get_child_count()):
		if not "@@" in $graphEdit.get_child(i).name and $graphEdit.get_child(i).name != "CLAYER":
			var node = _allNodes[$graphEdit.get_child(i).name]
			var type = node.get_type()
			
			var newDialog = {}
			newDialog["type"] = type
			newDialog["x"] = node.offset.x
			newDialog["y"] = node.offset.y
			
			match (type):
				"Entry Point":
					newDialog["entry"] = node.get_entry()
					newDialog["next"] = ""
					var connectionList = $graphEdit.get_connection_list()
					for i in range(connectionList.size()):
						var connection = connectionList[i]
						var from = connection[connection.keys()[0]]
						var to = connection[connection.keys()[2]]
						if from == node.name:
							newDialog["next"] = to
							if currentBegin == "":
								currentBegin = str(from)
				
				"Decision":
					newDialog["text"] = node.get_text()
					var choices = {}
					for i in range(node.get_decision_amount()):
						var decisionText = node.get_decision_text(i)
						var connectionList = $graphEdit.get_connection_list()
						var next
						for k in range(connectionList.size()):
							var connection = connectionList[k]
							var from = connection[connection.keys()[0]]
							var to = connection[connection.keys()[2]]
							if from == node.name:
								if connection[connection.keys()[1]] == i:
									next = to
						choices[str(i)] = { "next" : str(next), "text" : decisionText}
					newDialog["choices"] = choices
					
				"End":
					pass
					
				"Text":
					newDialog["speaker"] = node.get_speaker()
					newDialog["text"] = node.get_text()
					newDialog["next"] = ""
					var connectionList = $graphEdit.get_connection_list()
					for i in range(connectionList.size()):
						var connection = connectionList[i]
						var from = connection[connection.keys()[0]]
						var to = connection[connection.keys()[2]]
						if from == node.name:
							newDialog["next"] = to
							
				"Event":
					newDialog["event_type"] = node.get_event_type()
					var next_success = ""
					var next_failure = ""
					var connectionList = $graphEdit.get_connection_list()
					for i in range(connectionList.size()):
						var connection = connectionList[i]
						var from = connection[connection.keys()[0]]
						var to = connection[connection.keys()[2]]
						if from == node.name:
							if connection[connection.keys()[1]] == 0:
								next_success = to
							else:
								next_failure = to
					var event_params = {}
					for i in range(node.get_event_param_amount()):
						var val = node.get_event_param(i)
						event_params[str(i)] = val

					newDialog["event_params"] = event_params
					newDialog["next_success"] = next_success
					newDialog["next_failure"] = next_failure
				
				_:
					print("type doens't exist: " + str(node["type"]))
		
			newConversation[node.name] = newDialog
	newConversation["currentBegin"] = currentBegin
	
	dialogData[$dialogNameEdit.text] = newConversation
	file.open(filePath, file.WRITE)
	file.store_string(to_json(dialogData))
	file.close()

func _on_FileDialog_file_selected(filePath):
	_lastFile = filePath
	#print(_lastFile)
	# load
	$loadedDialogsSelection.get_popup().clear()
	$loadedDialogsSelection.disabled = false
	
	clear_all()
	# load dialogs
	var file = File.new()
	file.open(_lastFile, file.READ)
	var text = file.get_as_text()
	_loadedDialogs = parse_json(text)
	file.close()

	for i in range(_loadedDialogs.size()):
		$loadedDialogsSelection.get_popup().add_item(_loadedDialogs.keys()[i])

	if _loadedDialogs.size() == 1:
		_load_conversation(_loadedDialogs.keys()[0])


func _load_conversation(conversation):
	# load all dialogs
	#print("loading: " + conversation)
	
	var conv = _loadedDialogs[conversation]
	for c in range(conv.size()):
		var dial = conv[conv.keys()[c]]
		#print(dial) 
		if conv.keys()[c] == "currentBegin":
			#print("current")
			continue
		var arr = {}
		if dial.type != "Decision" and dial.type != "End" and dial.type != "Event":
			arr["next"] = dial.next
			_allConnections.append([str(conv.keys()[c]), 0, dial.next, 0])
		
		match (dial.type):
			"Entry Point":
				arr["entry"] = dial.entry
			"Decision":
				arr["text"] = dial.text
				arr["choices"] = dial.choices
			"End":
				pass
			"Text":
				arr["speaker"] = dial.speaker
				arr["text"] = dial.text
			"Event":
				arr["event_type"] = dial.event_type
				arr["event_params"] = dial.event_params
				arr["next_success"] = dial.next_success
				arr["next_failure"] = dial.next_failure
			_:
				print("type doens't exist: " + str(dial["type"]))
		#print(conv.keys()[c])
		arr["nodesIndex"] = str(conv.keys()[c])
		_create_node(dial.type, Vector2(float(dial.x), float(dial.y)), arr)
			
	for i in range(_allConnections.size()):
		var con = _allConnections[i]
		if con[2] == "":
			continue
		#print("connecting " + str(_allNodes[str(con[0])].name) + " to " + str(_allNodes[str(con[2])].name) + \
		#		" from port " + str(con[1]) + " to " + str(con[3]))
		$graphEdit.connect_node(_allNodes[str(con[0])].name, con[1], _allNodes[str(con[2])].name, con[3])


func clear_all():
	var it = 0
	for i in range($graphEdit.get_child_count()):
		if not "@@" in $graphEdit.get_child(it).name and $graphEdit.get_child(it).name != "CLAYER":
			var child = $graphEdit.get_child(it)
			$graphEdit.remove_child(child)
			child.queue_free()
		else:
			it += 1
			
	$graphEdit.clear_connections()
	$startNode.clear()
	$startNode.disabled = true
	_nodeIds = 0
	_entryIds = 0
	nodesIndex = 0
	_allConnections.clear()
	_allNodes.clear()
			
func _on_deleteAll_pressed():
	clear_all()

func _on_loadedDialogsSelection_item_selected(ID):
	clear_all()
	var conversation = $loadedDialogsSelection.get_popup().get_item_text(ID)
	_load_conversation(conversation)
	$dialogNameEdit.text = conversation

