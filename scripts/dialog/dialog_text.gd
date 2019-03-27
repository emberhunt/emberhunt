extends "res://scripts/dialog/dialog_base.gd"

class_name DialogText

export(float) var textSpeed = 1.0


func init(text):
	$text.set_visible_characters(0)
	$text.percent_visible = 0
	$text.set_bbcode(text)
	_started = false
	_finished = false
	
func start():
	$textSpeedTimer.wait_time = 0.01 * textSpeed
	$textSpeedTimer.start()
	_started = true

func _on_textSpeedTimer_timeout():
	$text.percent_visible += 0.01
	if $text.percent_visible >= 1.0:
		$textSpeedTimer.stop()
		_finished = true

func finish():
	$text.percent_visible = 1.0
	$textSpeedTimer.stop()
	_finished = true
