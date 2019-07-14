# Copyright 2019 Emberhunt Team
# https://github.com/emberhunt
# Licensed under the GNU General Public License v3.0 or later
# SPDX-License-Identifier: GPL-3.0-or-later

extends Control

var _instancer

func init(purpose : String, max_quantity, instancer):
	_instancer = instancer
	# Change the text
	get_node("Label").set_text("How much to "+purpose+"?")
	# Set the sliders values
	get_node("SpinBox").set_max(max_quantity)
	get_node("HSlider").set_max(max_quantity)

func _on_SpinBox_value_changed(value):
	# Change the HSlider's value
	if get_node("HSlider").get_value() != value:
		get_node("HSlider").set_value(value)


func _on_HSlider_value_changed(value):
	# Change the SpinBox's value
	if get_node("SpinBox").get_value() != value:
		get_node("SpinBox").set_value(value)


func _confirm():
	_instancer.asker_done(get_node("SpinBox").get_value())
	queue_free()


func _on_BG_pressed():
	queue_free()
