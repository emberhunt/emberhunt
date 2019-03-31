extends "res://scripts/dialog/dialog_base.gd"

signal on_button_pressed(buttonId)

var _next = []

func init(choices : Array):
	for i in range($vBoxContainer.get_child_count()):
		$vBoxContainer.get_child(0).free()
	
	for i in range(choices.size()):
		var button = Button.new()
		$vBoxContainer.add_child(button)
		$vBoxContainer.get_child(i).connect("pressed", self, "handle_button_pressed", [i])
		_next.append(choices[i][0])
		$vBoxContainer.get_child(i).text = choices[i][1]
		
	_finished = false

func handle_button_pressed(id):
	_finished = true
	emit_signal("on_button_pressed", id)

func finish():
	_finished = true

func get_next(i):
	return _next[i]
