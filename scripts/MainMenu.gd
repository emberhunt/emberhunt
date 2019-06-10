# Copyright 2019 Emberhunt Team
# https://github.com/emberhunt
# Licensed under the GNU General Public License v3.0 or later
# SPDX-License-Identifier: GPL-3.0-or-later

extends Control

func _ready():
	# Lower FPS for testing reasons
	#Engine.set_target_fps(5)
	$Label.set_text(Global.nickname)

func _on_ButtonPlay_pressed():
	Global.paused = false
	SoundPlayer.play(preload("res://assets/sounds/click.wav"))
	get_tree().change_scene("res://scenes/CharacterSelection.tscn")

func _on_ButtonSettings_pressed():
	SoundPlayer.play(preload("res://assets/sounds/click.wav"))
	get_tree().change_scene("res://scenes/Settings.tscn")

func _on_ButtonExit_pressed():
	SoundPlayer.play(preload("res://assets/sounds/click.wav"))
	get_tree().quit()

func _input(event):
	if event.is_action_pressed("ui_page_down"): # access attack creator
		get_tree().change_scene("res://dev_tools/AttackCreator.tscn")
