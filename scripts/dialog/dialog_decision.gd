extends "res://scripts/dialog/dialog_base.gd"

signal on_button_pressed(buttonId)

func init(choices : Array):
	for i in range(choices.size()):
		var button = Button.new()
		$vBoxContainer.add_child(button)
		$vBoxContainer.get_child(i).connect("pressed", self, "handle_button_pressed", [i])
		$vBoxContainer.get_child(i).text = choices[i]
	_finished = false

func handle_button_pressed(id):
	_finished = true
	emit_signal("on_button_pressed", id)

func finish():
	_finished = true