extends Node2D

var direction = 0
var attacking = false
var can_attack = true

export var stats = {
	damage = 1, 							# base damage
	damage_random = Vector2(0,0), 			# adds x to y damage
	fire_rate = 1.0, 						# attacks per second
	fire_rate_random = 0, 					# 0-1 to randomly change the firerate by fire_rate_random*100 % in both directions
	bullet_count = 1, 						# amount of bullets per attack
	bullet_count_random = Vector2(0,0), 	# adds x to y bullets per attack
	bullet_speed = 300, 					# speed of the bullet in pixels/sec
	bullet_speed_random = 0, 				# 0-1 to randomly change each bullets speed by bullet_speed_random*100 % in both directions
	bullet_range = 200, 					# distance the bullet will travel in pixels
	bullet_range_random = 0, 				# 0-1 to randomly change each bullets range by bullet_range_random*100 % in both directions
	bullet_spread = 0, 						# float(0-6) spreads all bullets in one single attack equally over bullet_spread radians
	bullet_spread_random = 0, 				# float(0-6)randomizes each bullets direction by -0.5*bullet_spread_random to 0.5*bullet_spread_random radians
	bullet_scale = 3, 						# scaling factor for the bullet
	bullet_scale_random = 0, 				# 0-1 to randomly change each bullets scale by bullet_scale_random*100 % in both directions
	bullet_knockback = 0, 					# add's a knockback effect in pixels per hit
	bullet_knockback_random = 0, 			# 0-1 to randomly change each bullets knockback by bullet_knockback_random*100 % in both directions
	bullet_pierce = 0, 						# number of enemies a bullet can pierce before it get's deleted
	bullet_pierce_random = Vector2(0,0), 	# adds x to y to the bullet_pierce
	bullet_effects = {}, 					# placeholder for ailments / effects a bullet may have | we have no parser for that yet
	bullet_color = Color(1,0,0,1), 			# if no gradient is defined, the bullet will be modulated with this value
	bullet_gradient = Gradient, 			# a color ramp to interpolate bullet colors based on traveled distance
	bullet_scene = preload("res://scenes/default_bullet.tscn") # pass a scene to add different bullets with custom behaviour
	}

func _process(delta):
	if attacking: # attack touchpad is in use
		get_node("weapon_sprite").show()
		if can_attack: # attack is not on cooldown
			_attack()
	else:
		get_node("weapon_sprite").hide()
		
func _attack():
	var extra_bullets = 0																				# 
	var extra_bullet_range = range(stats.bullet_count_random.x,stats.bullet_count_random.y+1)			# \
	if len(extra_bullet_range) != 0:																	#	calculate random_bullet_count
		extra_bullets = extra_bullet_range[randi()%len(extra_bullet_range)]								# /
	
	var rotation_step = -1																				# \
	if stats.bullet_spread != 0 and stats.bullet_count + extra_bullets > 1:								#	calculate spread step based on bullet_count and bullet_spread
		rotation_step = float(stats.bullet_spread) / float(stats.bullet_count+extra_bullets)			# /
	
	for bullet_number in range(stats.bullet_count+extra_bullets): 													# for each bullet do:
		var new_bullet = stats.bullet_scene.instance() 															# instance new bullet
		var bullet_rotation = rotation 																					# set base rotation to weapon rotation
		if rotation_step != -1:																							# if there is a fixed spread step
			bullet_rotation += (stats.bullet_count+extra_bullets)/PI * rotation_step*-1 + bullet_number * rotation_step 						# spread the bullets according to the calculated rotation step
		if stats.bullet_spread_random != 0: 																			# if there is a random spread
			bullet_rotation += rand_range(float(stats.bullet_spread_random)/2*-1,float(stats.bullet_spread_random)/2) 		# randomly spread each bullet between -0.5*bullet_spread_random to 0.5*bullet_spread_random radians
				
		new_bullet._ini(stats,global_position,bullet_rotation) 															# initialise new bullet, see default_bullet.gd
		$bullet_container.add_child(new_bullet) 																		# add bullet to the bullet container
	
	can_attack = false # disable attacks until cooldown passed
	$fire_rate.set_wait_time((1 / stats.fire_rate) * rand_range(1 - stats.fire_rate_random,1 + stats.fire_rate_random)) # set the fire_rate timer to the according time
	$fire_rate.start()

func _on_fire_rate_timeout(): # cooldown between 2 attacks passed, next attack ready
	can_attack = true
