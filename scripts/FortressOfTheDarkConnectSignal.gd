extends Node2D

func _ready():
	Global.WorldReady("FortressOfTheDark")
	
	if get_tree().get_current_scene().get_name() == "MainServer":
		return
	
	var path = "/root/"+get_tree().get_current_scene().get_name()+"/GUI/CanvasLayer/"
	
	get_node("pickupItems").init(path)
	get_node("chests").init(path)
	get_node("npcs").init(path)
	
	