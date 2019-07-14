# Copyright 2019 Emberhunt Team
# https://github.com/emberhunt
# Licensed under the GNU General Public License v3.0 or later
# SPDX-License-Identifier: GPL-3.0-or-later

extends VBoxContainer

var selected = ""

func changeFinishButtonState(state):
	if state:
		# Enable it
		get_node("../../Buttons/ButtonFinish").set_disabled(false) 
		get_node("../../Buttons/ButtonFinish/Label").set("custom_colors/font_color",Color(1,1,1))
	else:
		# Disable it
		get_node("../../Buttons/ButtonFinish").set_disabled(true) 
		get_node("../../Buttons/ButtonFinish/Label").set("custom_colors/font_color",Color(0.6431372549,0.6431372549,0.6431372549))

func _on_Knight_pressed():
	SoundPlayer.play(preload("res://assets/sounds/click.wav"))
	if get_node("Knight/Knight").is_pressed():
		selected = "knight"
		changeFinishButtonState(true)
		get_node("Berserker/Berserker").set_pressed(false)
		get_node("Assassin/Assassin").set_pressed(false)
		get_node("Sniper/Sniper").set_pressed(false)
		get_node("Hunter/Hunter").set_pressed(false)
		get_node("Pyromancer/Pyromancer").set_pressed(false)
		get_node("Brand/Brand").set_pressed(false)
		get_node("Herald/Herald").set_pressed(false)
		get_node("Redeemer/Redeemer").set_pressed(false)
		get_node("Druid/Druid").set_pressed(false)
	else:
		selected = ""
		changeFinishButtonState(false)


func _on_Berserker_pressed():
	SoundPlayer.play(preload("res://assets/sounds/click.wav"))
	if get_node("Berserker/Berserker").is_pressed():
		selected = "berserker"
		changeFinishButtonState(true)
		get_node("Knight/Knight").set_pressed(false)
		get_node("Assassin/Assassin").set_pressed(false)
		get_node("Sniper/Sniper").set_pressed(false)
		get_node("Hunter/Hunter").set_pressed(false)
		get_node("Pyromancer/Pyromancer").set_pressed(false)
		get_node("Brand/Brand").set_pressed(false)
		get_node("Herald/Herald").set_pressed(false)
		get_node("Redeemer/Redeemer").set_pressed(false)
		get_node("Druid/Druid").set_pressed(false)
	else:
		selected = ""
		changeFinishButtonState(false)


func _on_Assassin_pressed():
	SoundPlayer.play(preload("res://assets/sounds/click.wav"))
	if get_node("Assassin/Assassin").is_pressed():
		selected = "assassin"
		changeFinishButtonState(true)
		get_node("Knight/Knight").set_pressed(false)
		get_node("Berserker/Berserker").set_pressed(false)
		get_node("Sniper/Sniper").set_pressed(false)
		get_node("Hunter/Hunter").set_pressed(false)
		get_node("Pyromancer/Pyromancer").set_pressed(false)
		get_node("Brand/Brand").set_pressed(false)
		get_node("Herald/Herald").set_pressed(false)
		get_node("Redeemer/Redeemer").set_pressed(false)
		get_node("Druid/Druid").set_pressed(false)
	else:
		selected = ""
		changeFinishButtonState(false)


func _on_Sniper_pressed():
	SoundPlayer.play(preload("res://assets/sounds/click.wav"))
	if get_node("Sniper/Sniper").is_pressed():
		selected = "sniper"
		changeFinishButtonState(true)
		get_node("Knight/Knight").set_pressed(false)
		get_node("Berserker/Berserker").set_pressed(false)
		get_node("Assassin/Assassin").set_pressed(false)
		get_node("Hunter/Hunter").set_pressed(false)
		get_node("Pyromancer/Pyromancer").set_pressed(false)
		get_node("Brand/Brand").set_pressed(false)
		get_node("Herald/Herald").set_pressed(false)
		get_node("Redeemer/Redeemer").set_pressed(false)
		get_node("Druid/Druid").set_pressed(false)
	else:
		selected = ""
		changeFinishButtonState(false)


func _on_Hunter_pressed():
	SoundPlayer.play(preload("res://assets/sounds/click.wav"))
	if get_node("Hunter/Hunter").is_pressed():
		selected = "hunter"
		changeFinishButtonState(true)
		get_node("Knight/Knight").set_pressed(false)
		get_node("Berserker/Berserker").set_pressed(false)
		get_node("Assassin/Assassin").set_pressed(false)
		get_node("Sniper/Sniper").set_pressed(false)
		get_node("Pyromancer/Pyromancer").set_pressed(false)
		get_node("Brand/Brand").set_pressed(false)
		get_node("Herald/Herald").set_pressed(false)
		get_node("Redeemer/Redeemer").set_pressed(false)
		get_node("Druid/Druid").set_pressed(false)
	else:
		selected = ""
		changeFinishButtonState(false)


func _on_Pyromancer_pressed():
	SoundPlayer.play(preload("res://assets/sounds/click.wav"))
	if get_node("Pyromancer/Pyromancer").is_pressed():
		selected = "pyromancer"
		changeFinishButtonState(true)
		get_node("Knight/Knight").set_pressed(false)
		get_node("Berserker/Berserker").set_pressed(false)
		get_node("Assassin/Assassin").set_pressed(false)
		get_node("Sniper/Sniper").set_pressed(false)
		get_node("Hunter/Hunter").set_pressed(false)
		get_node("Brand/Brand").set_pressed(false)
		get_node("Herald/Herald").set_pressed(false)
		get_node("Redeemer/Redeemer").set_pressed(false)
		get_node("Druid/Druid").set_pressed(false)
	else:
		selected = ""
		changeFinishButtonState(false)


func _on_Brand_pressed():
	SoundPlayer.play(preload("res://assets/sounds/click.wav"))
	if get_node("Brand/Brand").is_pressed():
		selected = "brand"
		changeFinishButtonState(true)
		get_node("Knight/Knight").set_pressed(false)
		get_node("Berserker/Berserker").set_pressed(false)
		get_node("Assassin/Assassin").set_pressed(false)
		get_node("Sniper/Sniper").set_pressed(false)
		get_node("Hunter/Hunter").set_pressed(false)
		get_node("Pyromancer/Pyromancer").set_pressed(false)
		get_node("Herald/Herald").set_pressed(false)
		get_node("Redeemer/Redeemer").set_pressed(false)
		get_node("Druid/Druid").set_pressed(false)
	else:
		selected = ""
		changeFinishButtonState(false)


func _on_Herald_pressed():
	SoundPlayer.play(preload("res://assets/sounds/click.wav"))
	if get_node("Herald/Herald").is_pressed():
		selected = "herald"
		changeFinishButtonState(true)
		get_node("Knight/Knight").set_pressed(false)
		get_node("Berserker/Berserker").set_pressed(false)
		get_node("Assassin/Assassin").set_pressed(false)
		get_node("Sniper/Sniper").set_pressed(false)
		get_node("Hunter/Hunter").set_pressed(false)
		get_node("Pyromancer/Pyromancer").set_pressed(false)
		get_node("Brand/Brand").set_pressed(false)
		get_node("Redeemer/Redeemer").set_pressed(false)
		get_node("Druid/Druid").set_pressed(false)
	else:
		selected = ""
		changeFinishButtonState(false)


func _on_Redeemer_pressed():
	SoundPlayer.play(preload("res://assets/sounds/click.wav"))
	if get_node("Redeemer/Redeemer").is_pressed():
		selected = "redeemer"
		changeFinishButtonState(true)
		get_node("Knight/Knight").set_pressed(false)
		get_node("Berserker/Berserker").set_pressed(false)
		get_node("Assassin/Assassin").set_pressed(false)
		get_node("Sniper/Sniper").set_pressed(false)
		get_node("Hunter/Hunter").set_pressed(false)
		get_node("Pyromancer/Pyromancer").set_pressed(false)
		get_node("Brand/Brand").set_pressed(false)
		get_node("Herald/Herald").set_pressed(false)
		get_node("Druid/Druid").set_pressed(false)
	else:
		selected = ""
		changeFinishButtonState(false)


func _on_Druid_pressed():
	SoundPlayer.play(preload("res://assets/sounds/click.wav"))
	if get_node("Druid/Druid").is_pressed():
		selected = "druid"
		changeFinishButtonState(true)
		get_node("Knight/Knight").set_pressed(false)
		get_node("Berserker/Berserker").set_pressed(false)
		get_node("Assassin/Assassin").set_pressed(false)
		get_node("Sniper/Sniper").set_pressed(false)
		get_node("Hunter/Hunter").set_pressed(false)
		get_node("Pyromancer/Pyromancer").set_pressed(false)
		get_node("Brand/Brand").set_pressed(false)
		get_node("Herald/Herald").set_pressed(false)
		get_node("Redeemer/Redeemer").set_pressed(false)
	else:
		selected = ""
		changeFinishButtonState(false)