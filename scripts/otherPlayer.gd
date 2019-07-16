# Copyright 2019 Emberhunt Team
# https://github.com/emberhunt
# Licensed under the GNU General Public License v3.0 or later
# SPDX-License-Identifier: GPL-3.0-or-later

extends KinematicBody2D

var speed = 1
onready var goal = position

var enabled = false

func move(pos):
	goal = pos

func _process(delta):
	if (goal-position).length() > 1 and enabled:
		position += (goal-position).normalized()*speed*delta