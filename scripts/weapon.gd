extends Node2D

var direction = 0
var attacking = false

func _process(delta):
	if attacking:
		get_node("weapon_sprite").show()
	else:
		get_node("weapon_sprite").hide()