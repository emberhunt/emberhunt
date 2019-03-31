extends "default_graph_node.gd"

var next

func _ready():
	pass

func set_speaker_suggestions(suggestions : Array):
	for i in range(suggestions.size()):
		$hBoxContainer/speaker.add_item(suggestions[i])


func set_speaker(speaker):
	if speaker == "{player}":
		_on_dialogPartner_pressed()
		$hBoxContainer/speaker.text = speaker
	elif speaker == "{partner}":
		_on_player_pressed()
		$hBoxContainer/speaker.text = speaker

func get_speaker():
	return $hBoxContainer/speaker.text

func set_text(text):
	$text.text = text

func get_text():
	return $text.text

func _on_custom_pressed():
	$dialogPartner.pressed = false
	$player.pressed = false

func _on_dialogPartner_pressed():
	$player.pressed = ! $player.pressed
	$hBoxContainer/custom.pressed = false
	if $player.pressed:
		$hBoxContainer/speaker.text = "{player}"
	else:
		$hBoxContainer/speaker.text = "{partner}"

func _on_player_pressed():
	$dialogPartner.pressed = ! $dialogPartner.pressed
	$hBoxContainer/custom.pressed = false
	if $player.pressed:
		$hBoxContainer/speaker.text = "{player}"
	else:
		$hBoxContainer/speaker.text = "{partner}"


