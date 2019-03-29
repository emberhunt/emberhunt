extends "res://DialogEditor/default_graph_node.gd"

func _ready():
	pass


func _on_graphNodeEnd_close_request():
	if name == "graphNodeEnd":
		return 
	queue_free()