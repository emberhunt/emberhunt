extends Control


# For testing:
#func _process(delta):
#	positionWindowOnScreen(get_global_mouse_position(),get_viewport().size)


func positionWindowOnScreen(pos, screensize):
	var flipX = false
	var flipY = false
	if pos.x >= screensize.x/2.0:
		flipX = true
		pos.x -= $Background.rect_size.x
	if pos.y >= screensize.y/2.0:
		flipY = true
		pos.y -= $Background.rect_size.y
	
	if not flipY:
		if pos.y+$Background.rect_size.y > screensize.y:
			$Background.rect_position.y = screensize.y-$Background.rect_size.y
		else:
			$Background.rect_position.y = pos.y
	else:
		if pos.y < 0:
			$Background.rect_position.y = 0
		else:
			$Background.rect_position.y = pos.y
	
	if not flipX:
		if pos.x+$Background.rect_size.x+50 > screensize.x:
			$Background.rect_position.x = screensize.x-$Background.rect_size.x
		else:
			$Background.rect_position.x = pos.x+50
	else:
		if pos.x-50 < 0:
			$Background.rect_position.x = $Background.rect_size.x-$Background.rect_size.x
		else:
			$Background.rect_position.x = pos.x-50

func _on_ItemInfo_button_down():
	queue_free()
