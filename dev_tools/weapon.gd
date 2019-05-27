extends Node2D

var direction = 0
var attacking = false
var can_attack = true
var attacked_recently = false

export var stats = {
	min_damage = 1,
	max_damage = 1,
	min_fire_rate = 3.0,
	max_fire_rate = 3.0,
	min_bullets = 1,
	max_bullets = 1,
	min_speed = 75,
	max_speed = 75,
	min_range = 50,
	max_range = 50,
	bullet_spread = 0,
	bullet_spread_random = 0,
	min_scale = 1,
	max_scale = 1,
	min_knockback = 0,
	max_knockback = 0,
	min_pierces = 0,
	max_pierces = 0,
	rotation = 0,
	bullet_type = 0,
	color = [1,1,1,1],
	bullet_gradient = "",
	heavy_attack = false,
	attack_sound = "",
	impact_sound = "",
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
	
	var bullet_count = int(rand_range(stats.min_bullets,stats.max_bullets))
	
	# calculate spread step based on bullet_count and bullet_spread
	var rotation_step = -1
	if stats.bullet_spread != 0 and bullet_count > 1:
		rotation_step = float(stats.bullet_spread) / float(bullet_count)
	
	var bullets = []
	
	for bullet_number in range(bullet_count): # Create each bullet
		var bullet_data = {}
		randomize()
		var new_bullet = Global.loaded_bullets[stats.scene].instance()
		bullet_data['rotation'] = rotation
		# Rotate the bullet
		if rotation_step != -1:
			bullet_data['rotation'] += bullet_count/PI * rotation_step*-1 + bullet_number * rotation_step
		if stats.bullet_spread_random != 0:
			bullet_data['rotation'] += rand_range(float(stats.bullet_spread_random)/2*-1,float(stats.bullet_spread_random)/2)
		# Calculate speed and max_distance
		
		bullet_data['speed'] = int(rand_range(stats.min_speed, stats.max_speed))
		bullet_data['max_distance'] = int(rand_range(stats.min_range, stats.max_range))
		
		# Calculate damage
		bullet_data['damage'] = int(rand_range(stats.min_damage,stats.max_damage))
		
		# Calculate pierces
		bullet_data['pierces'] = int(rand_range(stats.min_pierces,stats.max_pierces))
		
		# Calculate knockback
		bullet_data['knockback'] = int(rand_range(stats.min_knockback, stats.max_knockback))
		
		# Calculate bullet scale
		bullet_data['scale'] = Vector2(1,1) * rand_range(stats.min_scale,stats.max_scale)
		
		bullet_data['gradient'] = stats.bullet_gradient
		bullet_data['color'] = Color(stats.color[0],stats.color[1],stats.color[2],stats.color[3])
		bullet_data['impact_sound'] = stats.impact_sound
		bullet_data['type_id'] = stats.bullet_type
		bullet_data['rotation_speed'] = stats.rotation
		bullet_data['scene'] = stats.scene
		
		bullets.append(bullet_data)
		# Spawn the bullet
		new_bullet._ini(bullet_data, "player", get_tree().get_network_unique_id(), global_position+Vector2(sin(bullet_data['rotation']), -cos(bullet_data['rotation']))*5)
		get_node("/root/"+get_tree().get_current_scene().get_name()+"/Entities/projectiles").add_child(new_bullet)
		
	# Send the bullet data to server
	var wait_time = (1 / rand_range(stats.min_fire_rate, stats.max_fire_rate))
	can_attack = false # disable attacks until cooldown passed
	$fire_rate.set_wait_time(wait_time)
	$fire_rate.start()

func _on_fire_rate_timeout():
	can_attack = true
