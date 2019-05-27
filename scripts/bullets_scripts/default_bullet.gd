extends KinematicBody2D

var origin = Vector2(0,0)
var direction = Vector2(0,-1)
var speed = 0
var max_travel_distance = 0
var rotation_speed = 0

var damage = 0
var knockback = 0
var pierce_left = 0

var gradient = null

var impact_sound = ""

var shooter = "" # player, enemy or npc
var shooter_name = "" 	# What to call the shooter; If the shooter is a player,
						# this variable will hold it's ID, if it's an enemy
						# or a NPC it will hold it's name.


func _ini(bullet_data, shter, shter_name, pos): # is called before the bullet is added to the scene
	origin = pos
	speed = bullet_data['speed'] 
	max_travel_distance = bullet_data['max_distance'] 
	damage = bullet_data['damage'] 
	pierce_left = bullet_data['pierces'] 
	knockback = bullet_data['knockback'] 
	scale = bullet_data['scale'] 
	
	shooter = shter
	shooter_name = shter_name
	
	# set position to weapon origin
	position = origin
	# rotate the bullet according to the weapon node
	direction = direction.rotated(bullet_data['rotation'])
	rotation = bullet_data['rotation'] 
	
	# if a gradient is defined:
	if bullet_data['gradient'] is Gradient:
		$Sprite.modulate = bullet_data['gradient'].get_color(0)
		gradient = bullet_data['gradient']
	else:
		$Sprite.modulate = bullet_data['color']
		
	impact_sound = bullet_data['impact_sound']
	
	$Sprite.frame = bullet_data['type_id']
	rotation_speed = bullet_data['rotation_speed']

func _physics_process(delta):
	move_and_slide(direction*speed)
	if gradient != null:
		# interpolate gradient colors based on travel distance
		$Sprite.modulate = gradient.interpolate(abs((position-origin).length()) / max_travel_distance)
	if abs((position-origin).length()) > max_travel_distance: # max travel distance reached? delete yourself!
		queue_free()
	if rotation_speed != 0:
		rotation += deg2rad(rotation_speed)*delta
		
func _hit():
	if impact_sound != "":
		SoundPlayer.play(SoundPlayer.loaded_sounds[impact_sound])
	if pierce_left <= 0:	# delete bullet if there is no remaining pierce
		queue_free()
	else:					# reduce remaining pierces by one
		pierce_left -= 1

func _on_Area2D_body_entered(body):
	# Check if its not an enemy or a player
	# Because that would mean it's a wall
	if not body.is_in_group("player") or body.is_in_group("enemy"):
		queue_free()
