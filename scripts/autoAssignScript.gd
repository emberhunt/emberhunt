# Copyright 2019 Emberhunt Team
# https://github.com/emberhunt
# Licensed under the GNU General Public License v3.0 or later
# SPDX-License-Identifier: GPL-3.0-or-later

extends Node

func _ready():
	# Make sure I am not the server
	if get_tree().get_current_scene().get_name() != "MainServer":
		# Load the client side code
		get_parent().set_script(preload("res://scripts/Networking.gd"))
	else:
		# Load the server side code
		get_parent().set_script(preload("res://server/scripts/MainServer.gd"))
	pass