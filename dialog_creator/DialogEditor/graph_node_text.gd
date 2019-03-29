extends "res://DialogEditor/default_graph_node.gd"

var next

func _ready():
	pass

func set_speaker_suggestions(suggestions : Array):
	for i in range(suggestions.size()):
		$speaker.add_item(suggestions[i])


func set_speaker(speaker):
	$speaker.text = speaker

func get_speaker():
	return $speaker.text

func set_text(text):
	$text.text = text

func get_text():
	return $text.text
