extends KinematicBody2D

var speed = 0 # Joystick Speed
var direction = 0 # Joystick direction
var motion = Vector2(0,0) # Movement vector
onready var player_sprite = get_parent().get_node("player_sprite") #Sprite node

func _process(delta):
	var motion = direction*speed*delta*Vector2(100, 100) #Calculate the movement vector using the joystick variables
	move_and_slide(motion)# Move according to the motion vector
	player_sprite.position = position
	