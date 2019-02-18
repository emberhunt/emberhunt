extends KinematicBody2D

var speed = 0
var direction = 0
var motion = Vector2(0,0)
#var player_sprite = get_parent().get_node("player_sprite")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var motion = direction*speed*delta*Vector2(100, 100)
	move_and_slide(motion)
	#if direction != 0:
	#	player_sprite.scale = ceil(direction)
	
