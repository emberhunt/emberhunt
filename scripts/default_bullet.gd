extends KinematicBody2D

# The player bullet's collision layer is set to 3:
# every object (including enemies) that should collide with it, need the same collision layer
# this will prevent collisions between players and player bullets, unless we define a PVP zone

var origin = Vector2(0,0)
var direction = Vector2(0,-1)
var speed = 0
var max_travel_distance = 0

var damage = 0
var knockback = 0
var pierce_left = 0
var effects = {}

var gradient = null


func _ini(stats, weapon_origin, weapon_rotation): # is called by weapon.gd before the bullet is added to the scene
	origin = weapon_origin # safe origin to calculate traveled distance
	position = origin # set position to weapon origin
	direction = direction.rotated(weapon_rotation) # rotate the bullet according to the weapon node
	rotation = weapon_rotation
	speed = stats.bullet_speed * (rand_range(1-stats.bullet_speed_random,1+stats.bullet_speed_random)) # value to multiply the direction with
	max_travel_distance = stats.bullet_range * (rand_range(1-stats.bullet_range_random,1+stats.bullet_range_random)) # maximum travel distance in pixel
	
	
	damage = stats.damage # set damage to be base damage
	var damage_range = range(stats.damage_random.x,stats.damage_random.y+1) # declare range of extra damage
	if len(damage_range) != 0: # if extra damage got atleast 2 different values
		damage += damage_range[randi()%len(damage_range)] # pick a random value and add it to damage
	
	pierce_left = stats.bullet_pierce # set remaining pierces to base pierce
	var pierce_range = range(stats.bullet_pierce_random.x,stats.bullet_pierce_random.y+1) # declare range of additional pierces
	if len(pierce_range) != 0: # if additional pierces got atleast 2 different values
		pierce_left += pierce_range[randi()%len(pierce_range)] # pick a random value and add it to remaining pierces
		
	knockback = stats.bullet_knockback * rand_range(1-stats.bullet_knockback_random,1+stats.bullet_knockback_random) # calculate knockback and it's randomness
	effects = stats.bullet_effects # safe effects of the bullet, ie poison or increased loot
	
	scale = Vector2(stats.bullet_scale,stats.bullet_scale) * rand_range(1-stats.bullet_scale_random,1+stats.bullet_scale_random) # calculate bullet scale and it's randomness
	if stats.bullet_gradient is Gradient: 								# if a gradient is defined:
		$Sprite.modulate = stats.bullet_gradient.get_color(0) 	# 	modulate to first gradient color
		gradient = stats.bullet_gradient								# 	safe gradient for interpolating colors based on travel distance
	else:																# if no gradient is defined:
		$Sprite.modulate = stats.bullet_color					#	modulate to bullet_color
	
func _physics_process(delta):
	move_and_slide(direction*speed)
	if gradient != null: # if we use a gradient
		$Sprite.modulate = gradient.interpolate(abs((position-origin).length()) / max_travel_distance) # interpolate gradient colors based on travel distance
	if abs((position-origin).length()) > max_travel_distance: # max travel distance reached? delete yourself!
		queue_free()
		
func _reduce_pierce(): # called by enemies colliding with this bullet
	if pierce_left <= 0:	# delete bullet if there is no remaining pierce
		queue_free()
	else:					# reduce remaining pierces by one
		pierce_left -= 1