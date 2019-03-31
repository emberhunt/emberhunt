extends Control

onready var _text := $textbackground/text

func _ready():
	_text.bbcode_enabled = true

func set_stats(stats : Dictionary):
	var text := ""
	_text.bbcode_enabled = true
	
	for i in range(stats.size()):
		var key = stats.keys()[i]
		var value = stats[key]
		text += "" + str(key) + ": " + str(value) + "\n"
	_text.set_text(text)