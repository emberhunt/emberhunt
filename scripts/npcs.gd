extends Node2D


var dialogSystem

var _openDialogButton
var _npc


func _ready():
	for i in range(get_child_count()):
		get_child(i).connect("on_interaction_range_entered", self, "interation_range_entered")
		get_child(i).connect("on_interaction_range_exited", self, "interation_range_exited")
		get_child(i).connect("on_sight_entered", self, "sight_range_entered")

func init(path):
	if get_tree().get_current_scene().get_name() != "MainServer":
		_openDialogButton = get_node(path + "/openDialog")
		_openDialogButton.connect("pressed", self, "start_conversation")
		_openDialogButton.get_child(0).connect("pressed", self, "start_conversation")
	

func interation_range_entered(npc):
	_npc = npc
	_openDialogButton.show()

func interation_range_exited(npc):
	_npc = npc
	_openDialogButton.hide()

func start_conversation():
	_openDialogButton.hide()
	get_node("/root/"+get_tree().get_current_scene().get_name()+"/GUI/CanvasLayer/dialogSystem"). \
			start_conversation(_npc.conversationName, _npc.npcName)

func sight_range_entered(npc):
	if _openDialogButton != null:
		_openDialogButton.hide()
