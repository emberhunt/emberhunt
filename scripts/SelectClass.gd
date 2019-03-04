extends VBoxContainer

var selected = ""

func changeFinishButtonState(state):
	if state == true:
		# Enable it
		get_node("../../Buttons/ButtonFinish").set_disabled(false) 
		get_node("../../Buttons/ButtonFinish/Label").set("custom_colors/font_color",Color(1,1,1))
	else:
		# Disable it
		get_node("../../Buttons/ButtonFinish").set_disabled(true) 
		get_node("../../Buttons/ButtonFinish/Label").set("custom_colors/font_color",Color(0.6431372549,0.6431372549,0.6431372549))

func _on_Knight_pressed():
	if get_node("Knight/Knight").is_pressed():
		selected = "Knight"
		changeFinishButtonState(true)
		get_node("Berserker/Berserker").set_pressed(false)
		get_node("Assasin/Assasin").set_pressed(false)
		get_node("Sniper/Sniper").set_pressed(false)
	else:
		selected = ""
		changeFinishButtonState(false)


func _on_Berserker_pressed():
	if get_node("Berserker/Berserker").is_pressed():
		selected = "Berserker"
		changeFinishButtonState(true)
		get_node("Knight/Knight").set_pressed(false)
		get_node("Assasin/Assasin").set_pressed(false)
		get_node("Sniper/Sniper").set_pressed(false)
	else:
		selected = ""
		changeFinishButtonState(false)


func _on_Assasin_pressed():
	if get_node("Assasin/Assasin").is_pressed():
		selected = "Assasin"
		changeFinishButtonState(true)
		get_node("Knight/Knight").set_pressed(false)
		get_node("Berserker/Berserker").set_pressed(false)
		get_node("Sniper/Sniper").set_pressed(false)
	else:
		selected = ""
		changeFinishButtonState(false)


func _on_Sniper_pressed():
	if get_node("Sniper/Sniper").is_pressed():
		selected = "Sniper"
		changeFinishButtonState(true)
		get_node("Knight/Knight").set_pressed(false)
		get_node("Assasin/Assasin").set_pressed(false)
		get_node("Assasin/Assasin").set_pressed(false)
	else:
		selected = ""
		changeFinishButtonState(false)
