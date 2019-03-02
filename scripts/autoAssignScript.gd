extends Node

func _ready():
	# Make sure I am not the server
	if get_tree().get_current_scene().get_name() != "@Networking@2":
		# Load the client side code
		get_parent().set_script(preload("res://scripts/Networking.gd"))
	pass