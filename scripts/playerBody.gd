# Copyright 2019 Emberhunt Team
# https://github.com/emberhunt
# Licensed under the GNU General Public License v3.0 or later
# SPDX-License-Identifier: GPL-3.0-or-later

extends KinematicBody2D

var direction = Vector2(0,0) # Joystick direction
var motion = Vector2(0,0) # Movement vector


func _process(delta):
	
	var motion = (Global.charactersData[Global.charID].agility+25)*direction #Calculate the movement vector using the joystick variables
	
	move_and_slide(motion)# Move according to the motion vector
	Networking.sendPosition(direction, delta)
