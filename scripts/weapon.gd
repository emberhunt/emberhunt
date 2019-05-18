extends Node2D

var direction = 0
var attacking = false
var can_attack = true
var attacked_recently = false

export var stats = {
	damage = 1, 							# base damage
	damage_random = Vector2(0,0), 			# adds random damage
	fire_rate = 3.0, 						# bullets per second
	fire_rate_random = 0, 					# 0-1 to randomly change the firerate by fire_rate_random*100 % in both directions
	bullet_count = 1, 						# amount of bullets per attack
	bullet_count_random = Vector2(0,0), 	# adds random bullets per attack
	bullet_speed = 75, 						# speed of the bullet in pixels/sec
	bullet_speed_random = 0, 				# 0-1 to randomly change each bullets speed by bullet_speed_random*100 % in both directions
	bullet_range = 50, 						# distance the bullet will travel in pixels
	bullet_range_random = 0, 				# 0-1 to randomly change each bullets range by bullet_range_random*100 % in both directions
	bullet_spread = 0, 						# float(0-6) spreads all bullets in one single attack equally over bullet_spread radians
	bullet_spread_random = 0, 				# float(0-6)randomizes each bullets direction by -0.5*bullet_spread_random to 0.5*bullet_spread_random radians
	bullet_scale = 1, 						# scaling factor for the bullet
	bullet_scale_random = 0, 				# 0-1 to randomly change each bullets scale by bullet_scale_random*100 % in both directions
	bullet_knockback = 0, 					# add's a knockback effect in pixels per hit
	bullet_knockback_random = 0, 			# 0-1 to randomly change each bullets knockback by bullet_knockback_random*100 % in both directions
	bullet_pierce = 0, 						# number of enemies a bullet can pierce before it get's deleted
	bullet_pierce_random = Vector2(0,0), 	# adds x to y to the bullet_pierce
	bullet_rotation = 0,					# rotate each bullet by x degree per second
	bullet_type_id = 0,						# which sprite the bullet will have
	bullet_color = Color(1,1,1,1), 			# if no gradient is defined, the bullet will be modulated with this value
	bullet_gradient = "",#Gradient, 		# a color ramp to interpolate bullet colors based on traveled distance
	heavy_attack = false,					# Heavy attacks only get shot when attackpad is released.
	attack_sound = "",						# Sound name from SoundPlayer.loaded_sounds
	impact_sound = "",						# Sound name from SoundPlayer.loaded_sounds
	scene = "default_bullet"
	}

func _process(delta):
	if attacking: # attack touchpad is in use
		if can_attack and not stats.heavy_attack:
			_attack()
		elif can_attack and stats.heavy_attack:
			attacked_recently = true
	else:
		if stats.heavy_attack and attacked_recently:
			_attack()
		attacked_recently = false
		
func _attack():
	if stats.attack_sound != "":
		SoundPlayer.play(SoundPlayer.loaded_sounds[stats.attack_sound],-10)
	
	# calculate random bullet count
	var extra_bullets = 0
	var extra_bullet_range = range(stats.bullet_count_random.x,stats.bullet_count_random.y+1)
	if len(extra_bullet_range) != 0:
		extra_bullets = extra_bullet_range[randi()%len(extra_bullet_range)]
	
	# calculate spread step based on bullet_count and bullet_spread
	var rotation_step = -1
	if stats.bullet_spread != 0 and stats.bullet_count + extra_bullets > 1:
		rotation_step = float(stats.bullet_spread) / float(stats.bullet_count+extra_bullets)
	
	var bullets = []
	
	for bullet_number in range(stats.bullet_count+extra_bullets): # Create each bullet
		var bullet_data = {}
		randomize()
		var new_bullet = Global.loaded_bullets[stats.scene].instance()
		bullet_data['rotation'] = rotation
		# Rotate the bullet
		if rotation_step != -1:
			bullet_data['rotation'] += (stats.bullet_count+extra_bullets)/PI * rotation_step*-1 + bullet_number * rotation_step
		if stats.bullet_spread_random != 0:
			bullet_data['rotation'] += rand_range(float(stats.bullet_spread_random)/2*-1,float(stats.bullet_spread_random)/2)
		bullet_data['position'] = global_position
		# Convert rotation to a normalized vector, and make the bullet spawn 5 pixels ahead of shooter
		bullet_data['position'] += Vector2(sin(bullet_data['rotation']),-cos(bullet_data['rotation']))*5
		
		# Calculate speed and max_distance
		bullet_data['speed'] = stats.bullet_speed * (rand_range(1-stats.bullet_speed_random,1+stats.bullet_speed_random))
		bullet_data['max_distance'] = stats.bullet_range * (rand_range(1-stats.bullet_range_random,1+stats.bullet_range_random))
		
		# Calculate damage
		bullet_data['damage'] = stats.damage
		bullet_data['damage'] += rand_range(stats.damage_random.x, stats.damage_random.y+1)
		
		# Calculate pierces
		bullet_data['pierces'] = stats.bullet_pierce
		bullet_data['pierces'] += rand_range(stats.bullet_pierce_random.x,stats.bullet_pierce_random.y+1)
		
		# Calculate knockback
		bullet_data['knockback'] = stats.bullet_knockback * rand_range(1-stats.bullet_knockback_random,1+stats.bullet_knockback_random)
		
		# Calculate bullet scale
		bullet_data['scale'] = Vector2(stats.bullet_scale,stats.bullet_scale) \
			* rand_range(1-stats.bullet_scale_random,1+stats.bullet_scale_random)
		
		bullet_data['gradient'] = stats.bullet_gradient
		bullet_data['color'] = stats.bullet_color
		bullet_data['impact_sound'] = stats.impact_sound
		bullet_data['type_id'] = stats.bullet_type_id
		bullet_data['rotation_speed'] = stats.bullet_rotation
		bullet_data['scene'] = stats.scene
		
		bullets.append(bullet_data)
		# Spawn the bullet
		new_bullet._ini(bullet_data, "player", get_tree().get_network_unique_id())
		get_node("/root/"+get_tree().get_current_scene().get_name()+"/Entities/projectiles").add_child(new_bullet)
		
	# Send the bullet data to server
	var wait_time = (1 / stats.fire_rate) * rand_range(1 - stats.fire_rate_random,1 + stats.fire_rate_random)
	Networking.shootBullets(bullets, stats.attack_sound)
	can_attack = false # disable attacks until cooldown passed
	$fire_rate.set_wait_time(wait_time)
	$fire_rate.start()

func _on_fire_rate_timeout():
	can_attack = true
