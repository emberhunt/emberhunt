extends "res://DialogEditor/dialog_base.gd"




func _ready():
	$offset/text.percent_visible = 0
	emit_signal("start_dialog")


func _on_textShowSpeed_timeout():
	if not $offset/text.percent_visible >= 100:
		$offset/text.percent_visible += 5





