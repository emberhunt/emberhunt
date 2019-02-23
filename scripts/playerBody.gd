extends KinematicBody2D

var speed = 0 # Joystick Speed
var direction = 0 # Joystick direction
var motion = Vector2(0,0) # Movement vector

func _process(delta):
	var motion = direction*speed*delta*Vector2(100, 100) #Calculate the movement vector using the joystick variables
	# PC testing
	if Input.is_action_pressed("ui_left"):		#\
		motion += Vector2(-10000,0)*delta			# |
	if Input.is_action_pressed("ui_right"):		# | \
		motion += Vector2(10000,0)*delta			# |  | - So you can move and shoot at the same time on pc
	if Input.is_action_pressed("ui_up"):		# | /
		motion += Vector2(0,-10000)*delta			# |
	if Input.is_action_pressed("ui_down"):		# |
		motion += Vector2(0,10000)*delta			#/
	move_and_slide(motion)# Move according to the motion vector
	