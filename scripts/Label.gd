extends Label

func _physics_process(delta):
	set_text(str($Timer.time_left))
	pass