# Copyright 2019 Emberhunt Team
# https://github.com/emberhunt
# Licensed under the GNU General Public License v3.0 or later
# SPDX-License-Identifier: GPL-3.0-or-later

extends TouchScreenButton

var radius = 100
var origin
onready var _playerBody : KinematicBody2D = null#get_parent().get_parent().get_node('body')

var touchPower = 0
var touchDirection = 0
var touchRotation = 0

var index

var disabled = false
var isPressed = false

func isInArea(pos):
	if pos.x<2*radius+150 and pos.y>get_viewport().size.y-(2*radius+110):
		return true
	return false

func init(playerBody : KinematicBody2D):
	if playerBody == null:
		print("no body")
		return
	_playerBody = playerBody


func _ready():
	# Adjust position on screen
	position.x = radius+60
	position.y = get_viewport().size.y-(radius+60)
	# Hide everything
	$buttonSprite.hide()
	$background.hide()
	origin = position


func _input(event):
	if event is InputEventScreenTouch:
		if not event.pressed and event.index == index:
			isPressed = false
			$buttonSprite.global_position = origin
			$buttonSprite.hide()
			$background.hide()
			_playerBody.speed = 0
		if event.pressed and not isPressed and isInArea(event.position):
			if not disabled:
				if Global.touchpadPosition == "Flexible":
					origin = event.position
					set_position(event.position)
				index = event.index
				isPressed = true
				var localPos = event.position - origin
				$buttonSprite.show()
				$background.show()
				$buttonSprite.global_position = event.position
				touchPower = localPos.length()
				touchDirection = localPos.normalized()
				if touchPower > radius:
					touchPower = radius
					$buttonSprite.global_position = radius*touchDirection + origin
				_playerBody.speed = touchPower
				_playerBody.direction = touchDirection
			
	if event is InputEventScreenDrag:
		if not disabled:
			if event.index == index:
				var localPos = event.position - origin
				if isPressed:
					index = event.index
					$buttonSprite.show()
					$background.show()
					$buttonSprite.global_position = event.position
					touchPower = localPos.length()
					touchDirection = localPos.normalized()
					if touchPower > radius:
						touchPower = radius
						$buttonSprite.global_position = radius*touchDirection + origin
					_playerBody.speed = touchPower
					_playerBody.direction = touchDirection