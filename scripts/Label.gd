extends Label

func _process(delta):
	set_text(str(get_node("../../../body").get_position()))
	pass