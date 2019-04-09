extends "default_graph_node.gd"

signal on_deletion

var next

func _on_graphNodeStart_close_request():
	emit_signal("on_deletion", $hBoxContainer/entry.text)
	queue_free()

func _on_graphNodeStart_resize_request(new_minsize):
	rect_size = new_minsize

func set_entry_point(id):
	$hBoxContainer/entry.text = str(id)

func get_entry():
	return $hBoxContainer/entry.text