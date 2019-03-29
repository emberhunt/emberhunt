extends GraphNode

class_name DefaultGraphNode

var _type


func _ready():
	pass


func _on_graphNode_resize_request(new_minsize):
	rect_size = new_minsize


func _on_graphNode_close_request():
	queue_free()

func set_type(type):
	_type = type

func get_type():
	return _type
