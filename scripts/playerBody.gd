# Copyright 2019 Emberhunt Team
# https://github.com/emberhunt
# Licensed under the GNU General Public License v3.0 or later
# SPDX-License-Identifier: GPL-3.0-or-later

extends KinematicBody2D

#var speed = 0 # Joystick Speed
var direction = Vector2(0,0) # Joystick direction
var motion = Vector2(0,0) # Movement vector


func _process(delta):
	var motion = (Global.charactersData[Global.charID].agility+25)*direction#*(speed/100) #Calculate the movement vector using the joystick variables

	# PC testing
	if Input.is_action_pressed("ui_left"):		#\
		motion += Vector2(-2500,0)*delta		# |
	if Input.is_action_pressed("ui_right"):		# | \
		motion += Vector2(2500,0)*delta		# |  | - So you can move and shoot at the same time on pc
	if Input.is_action_pressed("ui_up"):		# | /
		motion += Vector2(0,-2500)*delta		# |
	if Input.is_action_pressed("ui_down"):		# |
		motion += Vector2(0,2500)*delta		#/
	move_and_slide(motion)# Move according to the motion vector
	Networking.sendPosition(position)
