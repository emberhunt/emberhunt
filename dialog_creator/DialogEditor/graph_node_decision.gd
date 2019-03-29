extends "res://DialogEditor/default_graph_node.gd"


var _choicesAmount = 1

func _on_button_pressed():
	_spawn_choice()
	
func _spawn_choice():
	var additionalChoices = $additionalChoice
	remove_child($additionalChoice)
	var newChoice = $choice.duplicate()
	newChoice.get_node("choiceNumber").text = str(_choicesAmount)
	newChoice.get_node("lineEdit").text = ""
	add_child(newChoice)
	add_child(additionalChoices)
	set_slot(get_child_count() - 2, false, -1, Color.white, true, 0, Color(1, 0, 1, 1))
	
	_choicesAmount += 1

func set_text(text):
	$text.text = text

func get_text():
	return $text.text

func get_decision_text(choice):
	return get_child(4 + choice).get_node("lineEdit").text

func get_decision_amount():
	return _choicesAmount

func add_choice(choiceNumber, text, choiceNext):
	if str(choiceNumber) != "0":
		_spawn_choice()
	var lastChoice = get_child(get_child_count() - 2)
	lastChoice.get_node("choiceNumber").text = str(choiceNumber)
	lastChoice.get_node("lineEdit").text = text
	
	
