extends Node2D


var dialogSystem

var _openDialogButton

# count the npcs that are nearby
var _npcCounter = 0
var _npcInfo = {}
var _lastNpc := ""

func _ready():
	if get_tree().get_current_scene().get_name() == "MainServer":
		return
	for i in range(get_child_count()):
		get_child(i).connect("on_interaction_range_entered", self, "interation_range_entered")
		get_child(i).connect("on_interaction_range_exited", self, "interation_range_exited")
		get_child(i).connect("on_sight_entered", self, "sight_range_entered")

func init(path):
	if get_tree().get_current_scene().get_name() == "MainServer":
		return
	_openDialogButton = get_node(path + "/openDialog")
	_openDialogButton.connect("pressed", self, "start_conversation")
	_openDialogButton.get_child(0).connect("pressed", self, "start_conversation")

func interation_range_entered(npc):
	_npcInfo[npc.name] = [npc.conversationName, npc.npcName]
	_lastNpc = npc.name
	_openDialogButton.show()

func interation_range_exited(npc):
	_npcInfo.erase(npc.name)
	if not _npcInfo.empty():
		_lastNpc = _npcInfo.keys().back()
	_openDialogButton.hide()

func _update_npc_counter(count):
	_npcCounter += count
	if _npcCounter <= 0:
		_openDialogButton.hide()
	else:
		_openDialogButton.show()

func start_conversation():
	_openDialogButton.hide()
	if _npcInfo.empty():
		return
	get_node("/root/"+get_tree().get_current_scene().get_name()+"/GUI/CanvasLayer/dialogSystem"). \
			start_conversation(_npcInfo[_lastNpc][0], _npcInfo[_lastNpc][1])

func sight_range_entered(npc):
	if _openDialogButton != null:
		_openDialogButton.hide()
