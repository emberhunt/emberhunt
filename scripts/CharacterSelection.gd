# Copyright 2019 Emberhunt Team
# https://github.com/emberhunt
# Licensed under the GNU General Public License v3.0 or later
# SPDX-License-Identifier: GPL-3.0-or-later

extends VBoxContainer

# False if nothing selected, Int if selected
var selected = false


func _ready():
	# Disable 'Create' button if there already are 5 characters
	if Global.charactersData.size() >= 5:
		get_node("../../Buttons/ButtonCreate").set_disabled(true)
		get_node("../../Buttons/ButtonCreate/Label").set("custom_colors/font_color",Color(0.6431372549,0.6431372549,0.6431372549))
	# Check if there are any characters
	if Global.charactersData.size() == 0:
		get_node("Label").set_visible(true)
	# Generate List Items based on character data
	for i in range(Global.charactersData.size()):
		var scene = preload("res://scenes/CharacterSelectionListItem.tscn")
		var scene_instance = scene.instance()
		scene_instance.set_name("Char"+str(i))
		scene_instance.get_node("Class").set_text(Global.charactersData[str(i)]["class"])
		scene_instance.get_node("Level").set_text(str(Global.charactersData[str(i)]["level"])+"LvL")
		# Connect signals
		scene_instance.get_node("TextureButton").connect("pressed",self,"pressed", [str(i)])
		# Add the item to the scene
		add_child(scene_instance)
		move_child(scene_instance, 0)

func pressed(whichChar):
	SoundPlayer.play(preload("res://assets/sounds/click.wav"))
	if get_node("Char"+whichChar+"/TextureButton").is_pressed():
		selected = whichChar
		get_node("../../Buttons/ButtonPlay").set_disabled(false)
		get_node("../../Buttons/ButtonPlay/Label").set("custom_colors/font_color",Color(1,1,1))
	else:
		selected = false
		get_node("../../Buttons/ButtonPlay").set_disabled(true)
		get_node("../../Buttons/ButtonPlay/Label").set("custom_colors/font_color",Color(0.6431372549,0.6431372549,0.6431372549))
	for Char in get_children():
		# Check if this is not span or me
		if Char.get_name() == "span" or Char.get_name() == "Char"+whichChar or Char.get_name() == "Label":
			continue
		Char.get_node("TextureButton").set_pressed(false)
	pass