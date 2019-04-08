extends "res://scripts/dialog/dialog_base.gd"

export(float) var textSpeed = 1.0
var _next


func init(text):
	_next = text[0]
	$text.set_bbcode(text[1])
	$speakerBackground/speaker.text = text[2]
	$text.set_visible_characters(0)
	$text.percent_visible = 0
	_started = false
	_finished = false
	
func start():
	$text.set_visible_characters(0)
	$text.percent_visible = 0
	$textSpeedTimer.wait_time = 0.0015 * textSpeed
	$textSpeedTimer.start()
	_started = true
	_finished = false

func _on_textSpeedTimer_timeout():
	$text.percent_visible += 0.05
	if $text.percent_visible >= 1.0:
		$textSpeedTimer.stop()
		_finished = true

func finish():
	$text.percent_visible = 1.0
	$textSpeedTimer.stop()
	_finished = true

func get_next():
	return _next

func set_next(next):
	_next = next
