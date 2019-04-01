extends KinematicBody2D

var speed = 1
onready var goal = position

func move(pos):
	goal = pos

func _process(delta):
	if (goal-position).length() > 1:
		position += (goal-position).normalized()*speed*delta