# Copyright 2019 Emberhunt Team
# https://github.com/emberhunt
# Licensed under the GNU General Public License v3.0 or later
# SPDX-License-Identifier: GPL-3.0-or-later

extends Node

# This is the SERVER's side of networking

const SERVER_PORT = 22122
const MAX_PLAYERS = 10

const COMMANDS_PORT = 11234
var commandsThread = Thread.new()


var worlds = {}

var player_uuids_and_ids = {}

var lastShots = {}
#			"<player_id>" : timeWhenLastShot,

var given_rand_seeds = {}
#			"<player_id>" : [1651652163513525632, -1865653153222222322, 1653185168511123152, ...], <- seeds

var last_action_on_bag = {}
#			"<world name" : {
#				Vector2(bag position) : time when last action on bag occurred,
#				...
#			} 

func _ready():
	# Get ready
	# Check if serverData folder exists
	var dir = Directory.new()
	if not dir.dir_exists("user://serverData/"):
		# Create it
		dir.make_dir("user://serverData/")
		print("Creating user://serverData/")
	if not dir.dir_exists("user://serverData/accounts/"):
		dir.make_dir("user://serverData/accounts/")
		print("Creating user://serverData/accounts/")
	# Initialize server
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(peer)
	get_tree().set_meta("network_peer", peer)
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	print("Server initialized")
	
	
	# Start listening for commands on the UDP port
	commandsThread.start(self, "listenForCommands")
	print("For a list of commands, type \"help\".")
	print("Listening on port: " + str(SERVER_PORT) + " (GameServer)")
	
	# Create worlds
	# Fortress of the dark
	initWorld("FortressOfTheDark")

func _process(delta):
	# Check if any bags are old enough to be discarded
	# That's right. We should KILL old things
	for world in last_action_on_bag.keys():
		for bag in last_action_on_bag[world].keys():
			if last_action_on_bag[world][bag]+300<=OS.get_unix_time(): # Discard after 300 seconds of inactivity
				# Yeet the frick outta dat bag
				worlds[world].bags.erase(bag)
				last_action_on_bag[world].erase(bag)
	
	
	# Sync the worlds with all players
	for world in worlds.keys():
		for player in worlds[world].players.keys():
			var world_data = worlds[world].duplicate(true)
			# Do not send any private bags items data
			for bag in world_data.bags.keys():
				if world_data.bags[bag].has("player") and world_data.bags[bag].player != int(player):
					world_data.bags[bag].items = {}
			
			rpc_id(int(player), "receive_world_update", world, world_data)

# # # # # # # # # # # #
# CONNECTED FUNCTIONS #
# # # # # # # # # # # #

func _player_connected(id):
	print(str(id)+" connected; IP - "+get_tree().network_peer.get_peer_address(id))

func _player_disconnected(id):
	for world in worlds.keys():
		if worlds[world].players.has(id):
			get_node("/root/MainServer/"+world+"/Entities/players/" + str(id)).queue_free()
			worlds[world].players.erase(id)
			player_uuids_and_ids.erase(id)
	print(str(id)+" disconnected")

# # # # # # # # # # #
# REMOTE FUNCTIONS  #
# # # # # # # # # # #

remote func register_new_account(nickname):
	print("Received request to register new account from "+str(get_tree().get_rpc_sender_id()))
	if nickname.length() > 0 and nickname.length() <= 50:
		# Check if the nickname is alphanumerical
		var regex = RegEx.new()
		regex.compile("^[a-zA-Z0-9_]+$")
		if regex.search(nickname):
			if isNicknameFree(nickname):
				var uuid = generateRandomUUID(nickname)
				rpc_id(get_tree().get_rpc_sender_id(), "receive_new_uuid", uuid)
				print("New account registered")
			else:
				rpc_id(get_tree().get_rpc_sender_id(), "receive_new_uuid", false)
		else:
			rpc_id(get_tree().get_rpc_sender_id(), "receive_new_uuid", false)
	else:
		rpc_id(get_tree().get_rpc_sender_id(), "receive_new_uuid", false)

remote func send_character_data(uuid):
	var uuid_hash = uuid.sha256_text()
	# Check if the UUID is registered
	if not checkIfUuidIsRegistered(uuid_hash):
		# The UUID is not registered yet
		rpc_id(get_tree().get_rpc_sender_id(), "receive_character_data", false)
		print(str(get_tree().get_rpc_sender_id())+" tried to get character data, but the specified UUID is not registered.")
		return
	# Parse data.json
	var data = getUuidData(uuid_hash)
	# Send the data back
	rpc_id(get_tree().get_rpc_sender_id(), "receive_character_data", data)

remote func receive_new_character_data(uuid, data):
	var uuid_hash = uuid.sha256_text()
	if checkIfUuidIsRegistered(uuid_hash):
		# Check if the data is valid
		var classes = Global.init_stats.keys()
		if not (data in classes):
			print("Received invalid new character data (Bad class)")
		else:
			# Parse data.json
			var parsed = getUuidData(uuid_hash)
			# Check if player already has 5 characters
			if parsed.chars.size() < 5:
				# Register the new character
				parsed.chars[parsed.chars.size()] = {
					"class":data,
					"level":1,
					"experience":0,
					"max_hp": Global.init_stats[data].max_hp,
					"max_mp": Global.init_stats[data].max_mp,
					"strength": Global.init_stats[data].strength,
					"agility": Global.init_stats[data].agility,
					"magic": Global.init_stats[data].magic,
					"luck": Global.init_stats[data].luck,
					"physical_defense": Global.init_stats[data].physical_defense,
					"magic_defense": Global.init_stats[data].magic_defense,
					"inventory" : Global.init_stats[data].inventory
				}
				# Write the new data
				setUuidData(uuid_hash, parsed)
			else:
				print("Received new character data, but the account already has 5 characters (id: "+str(get_tree().get_rpc_sender_id())+")")
	else:
		print("Received new character data on an UUID which is not registered; ("+str(get_tree().get_rpc_sender_id())+")")

remote func check_if_nickname_is_free(nickname):
	if isNicknameFree(nickname):
		rpc_id(get_tree().get_rpc_sender_id(), "answer_is_nickname_free", true)
	else:
		rpc_id(get_tree().get_rpc_sender_id(), "answer_is_nickname_free", false)

remote func check_if_uuid_exists(uuid):
	var uuid_hash = uuid.sha256_text()
	if not checkIfUuidIsRegistered(uuid_hash):
		# The UUID is not registered yet
		rpc_id(get_tree().get_rpc_sender_id(), "answer_is_uuid_valid", true)
		return
	rpc_id(get_tree().get_rpc_sender_id(), "answer_is_uuid_valid", false)

remote func join_world(uuid, character_id, world):
	# Check if the world exists
	if world in worlds:
		var uuid_hash = uuid.sha256_text()
		# Check if uuid is registered
		if checkIfUuidIsRegistered(uuid_hash):
			# Check if the account has that character
			var account_data = getUuidData(uuid_hash)
			if str(character_id) in account_data.chars.keys():
				# Check if any other characters are playing right now
				for player_data in worlds[world].players.values():
					if account_data.nickname == player_data.nickname:
						# Another character is already playing
						return
				player_uuids_and_ids[get_tree().get_rpc_sender_id()] = {"uuid" : uuid_hash, "id" : character_id}
				# Spawn the player
				var scene = preload("res://scenes/otherPlayer.tscn")
				var scene_instance = scene.instance()
				scene_instance.set_name(str(get_tree().get_rpc_sender_id()))
				scene_instance.add_to_group("player")
				# Remove collissions between players
				for player in get_node("/root/MainServer/"+world+"/Entities/players").get_children():
					scene_instance.add_collision_exception_with(player)
				addSceneToGroup(scene_instance, world)
				get_node("/root/MainServer/"+world+"/Entities/players").add_child(scene_instance)
				worlds[world].players[get_tree().get_rpc_sender_id()] = {
					"position" : scene_instance.position,
					"health" : account_data.chars[str(character_id)]['max_hp'],
					"mana" : account_data.chars[str(character_id)]['max_mp'],
					"stats" : account_data.chars[str(character_id)],
					"nickname" : account_data.nickname,
					"joined" : OS.get_ticks_msec(),
					"deltas_sum" : 0,
					"inventory" : account_data.chars[str(character_id)]['inventory'],
					"account_character_id" : character_id
				}

remote func exit_world(world):
	# Check if the world exists
	if world in worlds:
		# Check if the character is in that world
		if get_tree().get_rpc_sender_id() in worlds[world].players:
			# Remove it from the world
			get_node("/root/MainServer/"+world+"/Entities/players/" + str(get_tree().get_rpc_sender_id())).queue_free()
			worlds[world].players.erase(get_tree().get_rpc_sender_id())

remote func send_position(world, direction, delta):
	var time_now = OS.get_ticks_msec()
	# Check if the world exists
	if world in worlds:
		# Check if the character is in that world
		if get_tree().get_rpc_sender_id() in worlds[world].players:
			var time_passed = float(time_now-worlds[world].players[get_tree().get_rpc_sender_id()].joined)/1000.0
			var deltas_sum = worlds[world].players[get_tree().get_rpc_sender_id()].deltas_sum+delta
			# Deltas sum can't be higher than the total time elapsed.
			if deltas_sum <= time_passed:
				# Update player's position
				var player_node = get_node("/root/MainServer/"+world+"/Entities/players/" + str(get_tree().get_rpc_sender_id()))
				
				var velocity = (worlds[world].players[get_tree().get_rpc_sender_id()].stats.agility+25)*direction.normalized()*delta
				
				# We're dividing the velocity by the server-side process delta
				# Because inside move_and_slide, they get multiplied, and we don't need that
				# So in the end get_process_delta_time() cancels out
				player_node.move_and_slide(velocity/get_process_delta_time())
				
				worlds[world].players[get_tree().get_rpc_sender_id()].position = player_node.position
				worlds[world].players[get_tree().get_rpc_sender_id()].deltas_sum = deltas_sum

remote func request_rand_seeds(how_many):
	var generator = RandomNumberGenerator.new()
	var seeds = []
	for iteration in range(how_many):
		generator.randomize()
		seeds.append(generator.seed)
	rpc_id(get_tree().get_rpc_sender_id(), "receive_rand_seeds", seeds)
	if not given_rand_seeds.has(get_tree().get_rpc_sender_id()):
		given_rand_seeds[get_tree().get_rpc_sender_id()] = []
	given_rand_seeds[get_tree().get_rpc_sender_id()] += seeds

remote func shoot_bullets(world, rotation):
	# Check if the world exists
	if world in worlds:
		# Check if the character is in that world
		if get_tree().get_rpc_sender_id() in worlds[world].players:
			# Get the weapon stats
			if not worlds[world].players[get_tree().get_rpc_sender_id()].inventory.has("0"):
				# The player has no weapon equipped
				return
			var stats = Global.items[worlds[world].players[get_tree().get_rpc_sender_id()].inventory["0"].item_id]
			
			# Check if the player should be able to shoot:
			if get_tree().get_rpc_sender_id() in lastShots.keys():
				if OS.get_ticks_msec() < lastShots[get_tree().get_rpc_sender_id()]-40: # 40ms is tolerated
					return
			# Shoot
			seed(given_rand_seeds[get_tree().get_rpc_sender_id()].pop_front())
			
			lastShots[get_tree().get_rpc_sender_id()] = OS.get_ticks_msec() + rand_range(stats.min_fire_rate, stats.max_fire_rate)
			var spawn_point = worlds[world].players[get_tree().get_rpc_sender_id()].position + Vector2(sin(rotation), -cos(rotation))*5
			
			
			var bullet_count = int(rand_range(stats.min_bullets,stats.max_bullets))
			
			# calculate spread step based on bullet_count and bullet_spread
			var rotation_step = -1
			if stats.bullet_spread != 0 and bullet_count > 1:
				rotation_step = float(stats.bullet_spread) / float(bullet_count)
			
			var bullets = []
			for bullet_number in range(bullet_count):
				var bullet_data = {}
				# Spawn the bullet
				seed(given_rand_seeds[get_tree().get_rpc_sender_id()].pop_front())
				var new_bullet = Global.loaded_bullets[stats['scene']].instance()
				
				# Shoot to the opposite direction if it's a heavy attack
				bullet_data['rotation'] = rotation + PI if stats.heavy_attack else rotation
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
				bullet_data['impact_sound'] = stats.impact_sound
				bullet_data['color'] = Color(stats.color[0],stats.color[1],stats.color[2],stats.color[3])
				bullet_data['type_id'] = stats.bullet_type
				bullet_data['rotation_speed'] = stats.rotation
				bullet_data['scene'] = stats.scene
				
				bullets.append(bullet_data)
				
				new_bullet._ini(bullet_data, "player", str(get_tree().get_rpc_sender_id()), spawn_point)
				get_node("/root/MainServer/"+world+"/Entities/projectiles/").add_child(new_bullet)
			rpc_all_in_world(world, "shoot_bullets", [world, bullets, stats.attack_sound, "player", str(get_tree().get_rpc_sender_id()), spawn_point])

remote func drop_item(world, slot, bag_pos, bag_slot, quantity):
	# Check if the world exists
	if world in worlds:
		# Check if the character is in that world
		if get_tree().get_rpc_sender_id() in worlds[world].players:
			# Check if the given slot IDs are in range
			if int(slot) in range(worlds[world].players[get_tree().get_rpc_sender_id()].stats.level+20) \
			and int(bag_slot) in range(20):
				# Check if the character has anything in that slot
				if worlds[world].players[get_tree().get_rpc_sender_id()].inventory.has(slot):
					# Check if the given bag position is close enough to the actual player
					if (worlds[world].players[get_tree().get_rpc_sender_id()].position-bag_pos).length()<=12:
						# Check if quantity was specified
						if quantity != -1:
							# Check if quantity is in range
							if quantity in range(1, worlds[world].players[get_tree().get_rpc_sender_id()].inventory[slot].quantity):
								# Check if there's a bag in the given position
								if worlds[world].bags.has(bag_pos):
									# There is a bag
									# Check if there's anything in the specified bag slot
									if not worlds[world].bags[bag_pos].items.has(bag_slot):
										# Hurray! We can proceed to drop the items
										# Get the item data
										var item_data = worlds[world].players[get_tree().get_rpc_sender_id()].inventory[slot].duplicate(true)
										item_data.quantity = quantity
										# Change the quantity of the item in the inventory
										worlds[world].players[get_tree().get_rpc_sender_id()].inventory[slot].quantity -= quantity
										# Save
										save_player_data(world, get_tree().get_rpc_sender_id())
										# Add the item to bag
										worlds[world].bags[bag_pos].items[bag_slot] = item_data
									else:
										return
								else:
									# There is no bag
									# We will have to create one
									# Get the item data
									var item_data = worlds[world].players[get_tree().get_rpc_sender_id()].inventory[slot].duplicate(true)
									item_data.quantity = quantity
									# Change the quantity of the item in the inventory
									worlds[world].players[get_tree().get_rpc_sender_id()].inventory[slot].quantity -= quantity
									# Save
									save_player_data(world, get_tree().get_rpc_sender_id())
									# Add the bag with the item
									worlds[world].bags[bag_pos] = {
										"items": {
											bag_slot : item_data
										}
									}
								update_last_bag_action_time(world, bag_pos)
						else:
							# Check if there's a bag in the given position
							if worlds[world].bags.has(bag_pos):
								# There is a bag
								# Check if there's anything in the specified bag slot
								if not worlds[world].bags[bag_pos].items.has(bag_slot):
									# Hurray! We can proceed to drop the item
									# Get the item data
									var item_data = worlds[world].players[get_tree().get_rpc_sender_id()].inventory[slot]
									# Remove the item from the inventory
									worlds[world].players[get_tree().get_rpc_sender_id()].inventory.erase(slot)
									# Save
									save_player_data(world, get_tree().get_rpc_sender_id())
									# Add the item to bag
									worlds[world].bags[bag_pos].items[bag_slot] = item_data
								else:
									return
							else:
								# There is no bag
								# We will have to create one
								# Get the item data
								var item_data = worlds[world].players[get_tree().get_rpc_sender_id()].inventory[slot]
								# Remove the item from the inventory
								worlds[world].players[get_tree().get_rpc_sender_id()].inventory.erase(slot)
								# Save
								save_player_data(world, get_tree().get_rpc_sender_id())
								# Add the bag with the item
								worlds[world].bags[bag_pos] = {
									"items": {
										bag_slot : item_data
									}
								}
							update_last_bag_action_time(world, bag_pos)

remote func pickup_item(world, bag_pos, bag_slot, inv_slot, quantity):
	# Check if the world exists
	if world in worlds:
		# Check if the character is in that world
		if get_tree().get_rpc_sender_id() in worlds[world].players:
			# Check if the given slot IDs are in range
			if int(inv_slot) in range(worlds[world].players[get_tree().get_rpc_sender_id()].stats.level+20) \
			and int(bag_slot) in range(20):
				# Check if the character has anything in that slot
				if not worlds[world].players[get_tree().get_rpc_sender_id()].inventory.has(inv_slot):
					# Check if the given bag position is close enough to the actual player
					if (worlds[world].players[get_tree().get_rpc_sender_id()].position-bag_pos).length()<=12:
						# Check if there's a bag in the given position
						if worlds[world].bags.has(bag_pos):
							# Check if there's anything in the specified bag slot
							if worlds[world].bags[bag_pos].items.has(bag_slot):
								# Check if the item is allowed in that slot
								if item_allowed_in_slot(world, get_tree().get_rpc_sender_id(), inv_slot, worlds[world].bags[bag_pos].items[bag_slot].item_id):
									# Check if quantity was specified
									if quantity != -1:
										# Check if quantity is in range
										if quantity in range(1, worlds[world].bags[bag_pos].items[bag_slot].quantity):
											# Nice
											# Get the item data
											var item_data = worlds[world].bags[bag_pos].items[bag_slot].duplicate(true)
											item_data.quantity = quantity
											
											# Decrease the bag item's quantity
											worlds[world].bags[bag_pos].items[bag_slot].quantity -= quantity
											
											update_last_bag_action_time(world, bag_pos)
											
											# Add the item to the inventory
											worlds[world].players[get_tree().get_rpc_sender_id()].inventory[inv_slot] = item_data
											print("Picking up "+str(quantity)+" "+str(item_data.item_id)+" to inventory slot "+str(inv_slot))
											# Save
											save_player_data(world, get_tree().get_rpc_sender_id())
									else:
										# Pick it up
										# Get the item data
										var item_data = worlds[world].bags[bag_pos].items[bag_slot]
										# Remove the item from the bag
										worlds[world].bags[bag_pos].items.erase(bag_slot)
										
										update_last_bag_action_time(world, bag_pos)
										
										# if the bag is empty, remove it altogether
										if worlds[world].bags[bag_pos].items.size() == 0:
											worlds[world].bags.erase(bag_pos)
											remove_last_bag_action_time(world, bag_pos)
										# Add the item to the inventory
										worlds[world].players[get_tree().get_rpc_sender_id()].inventory[inv_slot] = item_data
										# Save
										save_player_data(world, get_tree().get_rpc_sender_id())

remote func change_inventory_layout(world, new_layout):
	# Check if the world exists
	if world in worlds:
		# Check if the character is in that world
		if get_tree().get_rpc_sender_id() in worlds[world].players:
			# In a valid layout change, all the item types should be the same,
			# The sums of quantities of each item should also be the same,
			# Slot IDs can change.
			# We will need to check if the slot IDs are in range
			for slot_id in new_layout.keys():
				if not (int(slot_id) in range(worlds[world].players[get_tree().get_rpc_sender_id()].stats.level+20) ):
					return
			# OK, now check if the same items are present
			
			# Get the new item ids list
			var new_items = new_layout.values()
			var new_item_ids = []
			for item in new_items:
				if not (item.item_id in new_item_ids):
					new_item_ids.append(item.item_id)
			new_item_ids.sort()
			
			# Get the old item ids list
			var old_items = worlds[world].players[get_tree().get_rpc_sender_id()].inventory.values()
			var old_item_ids = []
			for item in old_items:
				if not (item.item_id in old_item_ids):
					old_item_ids.append(item.item_id)
			old_item_ids.sort()
			
			# Compare them
			if str(new_item_ids) == str(old_item_ids):
				# Very cool.
				# Now lets check if the items have the same quantities overall
				
				# Get the new items quantities
				var new_items_quantities = {}
				for item in new_items:
					if new_items_quantities.has(item.item_id):
						new_items_quantities[item.item_id] += item.quantity
					else:
						new_items_quantities[item.item_id] = item.quantity
				
				# Get the old items quantities
				var old_items_quantities = {}
				for item in old_items:
					if old_items_quantities.has(item.item_id):
						old_items_quantities[item.item_id] += item.quantity
					else:
						old_items_quantities[item.item_id] = item.quantity
				
				# Compare the old quantities to the new ones
				for item_id in new_items_quantities.keys():
					if old_items_quantities[item_id] != new_items_quantities[item_id]:
						return
				
				# Now check all the items in special slots to make sure they can be there
				for special_slot in range(1):
					if new_layout.has(str(special_slot)):
						# Check if it's allowed
						if not item_allowed_in_slot(world, get_tree().get_rpc_sender_id(), str(special_slot), new_layout[str(special_slot)].item_id):
							# ಠ(•̀o•́)ง
							return
				
				# Very very cool. Lets update the layout!
				worlds[world].players[get_tree().get_rpc_sender_id()].inventory = new_layout
				# Save
				save_player_data(world, get_tree().get_rpc_sender_id())

remote func change_bag_layout(world, bag_pos, new_layout):
	# Check if the world exists
	if world in worlds:
		# Check if the character is in that world
		if get_tree().get_rpc_sender_id() in worlds[world].players:
			# Check if the given bag position is close enough to the actual player
			if (worlds[world].players[get_tree().get_rpc_sender_id()].position-bag_pos).length()<=12:
				# Check if there's a bag in the given position
				if worlds[world].bags.has(bag_pos):
					# In a valid layout change, all the item types should be the same,
					# The sums of quantities of each item should also be the same,
					# Slot IDs can change.
					# We will need to check if the slot IDs are in range
					for slot_id in new_layout.keys():
						if not (int(slot_id) in range(20) ):
							return
					# OK, now check if the same items are present
					
					# Get the new item ids list
					var new_items = new_layout.values()
					var new_item_ids = []
					for item in new_items:
						if not (item.item_id in new_item_ids):
							new_item_ids.append(item.item_id)
					new_item_ids.sort()
					
					# Get the old item ids list
					var old_items = worlds[world].bags[bag_pos].items.values()
					var old_item_ids = []
					for item in old_items:
						if not (item.item_id in old_item_ids):
							old_item_ids.append(item.item_id)
					old_item_ids.sort()
					
					# Compare them
					if str(new_item_ids) == str(old_item_ids):
						# Very cool.
						# Now lets check if the items have the same quantities overall
						
						# Get the new items quantities
						var new_items_quantities = {}
						for item in new_items:
							if new_items_quantities.has(item.item_id):
								new_items_quantities[item.item_id] += item.quantity
							else:
								new_items_quantities[item.item_id] = item.quantity
						
						# Get the old items quantities
						var old_items_quantities = {}
						for item in old_items:
							if old_items_quantities.has(item.item_id):
								old_items_quantities[item.item_id] += item.quantity
							else:
								old_items_quantities[item.item_id] = item.quantity
						
						# Compare the old quantities to the new ones
						for item_id in new_items_quantities.keys():
							if old_items_quantities[item_id] != new_items_quantities[item_id]:
								return
						
						# Very very cool. Lets update the layout!
						worlds[world].bags[bag_pos].items = new_layout
						
						update_last_bag_action_time(world, bag_pos)

remote func swap_item(world, inv_slot_id, bag_slot_id, bag_pos):
	# Check if the world exists
	if world in worlds:
		# Check if the character is in that world
		if get_tree().get_rpc_sender_id() in worlds[world].players:
			# Check if the given bag position is close enough to the actual player
			if (worlds[world].players[get_tree().get_rpc_sender_id()].position-bag_pos).length()<=12:
				# Check if there's a bag in the given position
				if worlds[world].bags.has(bag_pos):
					# Check if the slot IDs are in range
					if int(inv_slot_id) in range(worlds[world].players[get_tree().get_rpc_sender_id()].stats.level+20) \
					and int(bag_slot_id) in range(20):
						# Check if the character has anything in that slot
						if worlds[world].players[get_tree().get_rpc_sender_id()].inventory.has(inv_slot_id):
							# Check if the bag has anything in that slot
							if worlds[world].bags[bag_pos].items.has(bag_slot_id):
								# Check if the bag item is allowed in that inventory slot
								if item_allowed_in_slot(world, get_tree().get_rpc_sender_id(), inv_slot_id, worlds[world].bags[bag_pos].items[bag_slot_id].item_id):
									# Proceed to swap the items
									var bag_item_info = worlds[world].bags[bag_pos].items[bag_slot_id].duplicate(true)
									worlds[world].bags[bag_pos].items[bag_slot_id] = \
										worlds[world].players[get_tree().get_rpc_sender_id()].inventory[inv_slot_id].duplicate(true)
									worlds[world].players[get_tree().get_rpc_sender_id()].inventory[inv_slot_id] = bag_item_info
									# Save
									save_player_data(world, get_tree().get_rpc_sender_id())
									update_last_bag_action_time(world, bag_pos)

remote func merge_item(world, inv_slot_id, bag_slot_id, bag_pos, target_bag):
	# Check if the world exists
	if world in worlds:
		# Check if the character is in that world
		if get_tree().get_rpc_sender_id() in worlds[world].players:
			# Check if the given bag position is close enough to the actual player
			if (worlds[world].players[get_tree().get_rpc_sender_id()].position-bag_pos).length()<=12:
				# Check if there's a bag in the given position
				if worlds[world].bags.has(bag_pos):
					# Check if the slot IDs are in range
					if int(inv_slot_id) in range(worlds[world].players[get_tree().get_rpc_sender_id()].stats.level+20) \
					and int(bag_slot_id) in range(20):
						# Check if the character has anything in that slot
						if worlds[world].players[get_tree().get_rpc_sender_id()].inventory.has(inv_slot_id):
							# Check if the bag has anything in that slot
							if worlds[world].bags[bag_pos].items.has(bag_slot_id):
								# Get the variables of items ready
								var first_item
								var second_item
								if target_bag:
									first_item = worlds[world].players[get_tree().get_rpc_sender_id()].inventory[inv_slot_id].duplicate(true)
									second_item = worlds[world].bags[bag_pos].items[bag_slot_id].duplicate(true)
								else:
									second_item = worlds[world].players[get_tree().get_rpc_sender_id()].inventory[inv_slot_id].duplicate(true)
									first_item = worlds[world].bags[bag_pos].items[bag_slot_id].duplicate(true)
								# Check if the item types are the same
								if first_item.item_id == second_item.item_id:
									# Check if the item type is stackable
									if Global.item_types[ Global.items[ first_item.item_id ].type ].has("stack_size") \
									and Global.item_types[ Global.items[ first_item.item_id ].type ].stack_size > 1:
										# Also neither of the items should be full
										if first_item.quantity < Global.item_types[ Global.items[ first_item.item_id ].type ].stack_size \
										and second_item.quantity < Global.item_types[ Global.items[ second_item.item_id ].type ].stack_size:
											
											# Ok, we are now sure that this merge is valid
											# Now we need to find out if this is a part merge, or a full merge
											if (first_item.quantity+second_item.quantity) > \
												Global.item_types[ Global.items[ first_item.item_id ].type ].stack_size:
												# Partial merge
												
												var second_item_new_quantity = Global.item_types[ Global.items[ first_item.item_id ].type ].stack_size
												var first_item_new_quantity = first_item.quantity - (second_item_new_quantity - second_item.quantity)
												
												if target_bag:
													worlds[world].players[get_tree().get_rpc_sender_id()].inventory[inv_slot_id].quantity = first_item_new_quantity
													worlds[world].bags[bag_pos].items[bag_slot_id].quantity = second_item_new_quantity
												else:
													worlds[world].players[get_tree().get_rpc_sender_id()].inventory[inv_slot_id].quantity = second_item_new_quantity
													worlds[world].bags[bag_pos].items[bag_slot_id].quantity = first_item_new_quantity
												
											else:
												# Full merge
												if target_bag:
													worlds[world].players[get_tree().get_rpc_sender_id()].inventory.erase(inv_slot_id)
													worlds[world].bags[bag_pos].items[bag_slot_id].quantity = first_item.quantity+second_item.quantity
												else:
													worlds[world].bags[bag_pos].items.erase(bag_slot_id)
													worlds[world].players[get_tree().get_rpc_sender_id()].inventory[inv_slot_id].quantity = first_item.quantity+second_item.quantity
											
											update_last_bag_action_time(world, bag_pos)


# # # # # # # # # # #
# NORMAL FUNCTIONS  #
# # # # # # # # # # #

func generateRandomUUID(nickname):
	var intToStr = {0 : 0,
					1 : 1,
					2 : 2,
					3 : 3,
					4 : 4,
					5 : 5,
					6 : 6,
					7 : 7,
					8 : 8,
					9 : 9,
					10 : "a",
					11 : "b",
					12 : "c",
					13 : "d",
					14 : "e",
					15 : "f",
					16 : "g",
					17 : "h",
					18 : "i",
					19 : "j",
					20 : "k",
					21 : "l",
					22 : "m",
					23 : "n",
					24 : "o",
					25 : "p",
					26 : "q",
					27 : "r",
					28 : "s",
					29 : "t",
					30 : "u",
					31 : "v",
					32 : "w",
					33 : "x",
					34 : "y",
					35 : "z",
					36 : "A",
					37 : "B",
					38 : "C",
					39 : "D",
					40 : "E",
					41 : "F",
					42 : "G",
					43 : "H",
					44 : "I",
					45 : "J",
					46 : "K",
					47 : "L",
					48 : "M",
					49 : "N",
					50 : "O",
					51 : "P",
					52 : "Q",
					53 : "R",
					54 : "S",
					55 : "T",
					56 : "U",
					57 : "V",
					58 : "W",
					59 : "X",
					60 : "Y",
					61 : "Z"}
	var uuid = ""
	# Generate random UUID
	for i in range(24):
		randomize()
		var x = intToStr[randi()%62]
		uuid = uuid+str(x)
	var uuid_hash = uuid.sha256_text()
	# check if the uuid is already taken
	if checkIfUuidIsRegistered(uuid_hash):
		return generateRandomUUID(nickname)
	# continue if it's not
	# Create the account's directory
	var dir = Directory.new()
	dir.make_dir("user://serverData/accounts/"+uuid_hash)
	# Data stored in data.json
	var data = {
		"nickname" : nickname.replace("\"", ""),
		"chars" : {}
	}
	setUuidData(uuid_hash,data)
	return uuid

func checkIfUuidIsRegistered(uuid):
	# Check if the UUID is registered
	var dir = Directory.new()
	if not dir.dir_exists("user://serverData/accounts/"+uuid):
		return false
	return true

func isNicknameFree(nickname):
	var contents = listFolderContent("user://serverData/accounts/")
	for account in contents:
		var file = File.new()
		file.open("user://serverData/accounts/"+account+"/data.json", file.READ)
		var text = file.get_as_text()
		var parsed = parse_json(text)
		file.close()
		if nickname == parsed.nickname:
			return false
	return true

func getUuidFromNickname(nickname):
	var contents = listFolderContent("user://serverData/accounts/")
	for account in contents:
		var file = File.new()
		file.open("user://serverData/accounts/"+account+"/data.json", file.READ)
		var text = file.get_as_text()
		var parsed = parse_json(text)
		file.close()
		if nickname == parsed.nickname:
			return account
	return null

func setUuidData(uuid_hash, data):
	var file = File.new()
	if file.open("user://serverData/accounts/"+uuid_hash+"/data.json", File.WRITE) != 0:
		print("Error opening file user://serverData/accounts/"+uuid_hash+"/data.json")
		return
	file.store_line(JSON.print(data))
	file.close()

func getUuidData(uuid_hash):
	var path = "user://serverData/accounts/"+uuid_hash+"/"
	var file = File.new()
	file.open(path+"data.json", file.READ)
	var text = file.get_as_text()
	var parsed = parse_json(text)
	file.close()
	return parsed

func listFolderContent(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)
	dir.list_dir_end()
	return files

func addSceneToGroup(node, group):
	node.add_to_group(group)
	if node is KinematicBody2D or \
		node is RigidBody2D or \
		node is StaticBody2D:
			for world in worlds.keys():
				if not world == group:
					addWorldToCollisionExceptions(node, get_node("/root/MainServer/"+world))
	if node.get_child_count() > 0:
		for N in node.get_children():
			addSceneToGroup(N, group)

func addWorldToCollisionExceptions(node, exception):
	# Only these nodes can be added to the exceptions list
	if exception is KinematicBody2D or \
		exception is RigidBody2D or \
		exception is StaticBody2D:
			node.add_collision_exception_with(exception)
	if exception.get_child_count() > 0:
		for E in exception.get_children():
			addWorldToCollisionExceptions(node, E)

func rpc_all_in_world(world, function_name, args = [], exceptions = []):
	# Check if world exists
	if world in worlds:
		for player_id in worlds[world].players.keys():
			if not (player_id in exceptions):
				callv("rpc_id", [player_id, function_name]+args)

func listenForCommands(userdata):
	# Get the password hash from cp.pswd
	var pswd_file = File.new()
	if pswd_file.open("res://server/cp.pswd", File.READ) != 0:
		print("Error opening cp.pswd")
		return
	var password = pswd_file.get_as_text()
	var server = TCP_Server.new()
	if server.listen(COMMANDS_PORT) != OK:
		print("Error listening on port: "+ str(COMMANDS_PORT) + " (Commands)")
	else:
		print("Listening on port: " + str(COMMANDS_PORT) + " (Commands)")
	var connections = []
	var authenticated = []
	while true:
		# Accept new connections
		if server.is_connection_available(): # check if someone's trying to connect
			var client = server.take_connection() # accept connection
			connections.append(client)
		
		# Accept new packets from connnections
		# and handle disconnections
		for client in connections:
			# Accept packets
			if client.get_available_bytes() > 0: # There are bytes received
				var bytes = client.get_string(client.get_available_bytes())
				if not bytes.ends_with("\n"):
					print("Received corrupted stream of bytes on the commands port ("+str(COMMANDS_PORT)+")")
				else:
					# Process the command
					bytes = bytes.rstrip("\n")
					# Check if the connection is authenticated yet
					if client in authenticated:
						# Process command
						execCommand(bytes, client)
					else:
						if bytes.sha256_text() == password:
							client.put_data("You are now authenticated \n".to_utf8())
							authenticated.append(client)
						else:
							client.put_data("Wrong password\n".to_utf8())
				
			# Handle disconnections
			if client.get_status() == 0: # NOT connected
				connections.erase( client )
				authenticated.erase( client )

func execCommand(command, connection):
	print("$ "+command)
	# Check if the command exists
	var directory = Directory.new();
	var regexNonSpace = RegEx.new()
	regexNonSpace.compile("[^ ]")
	# If the command is just spaces then ignore it
	if command == "" or not regexNonSpace.search(command):
		return
	else:
		# Split the input to command and args
		var regexArgs = RegEx.new()
		regexArgs.compile("(?:(?:\\s|^)(((?<!\\\\)\\\"|(?<!\\\\)')?.+?(?(2)(?<!\\\\)\\2|)(?=\\s|$)))")
		var args = regexArgs.search_all(command)
		# Check if that command exists
		if directory.file_exists("res://server/commands/"+args[0].get_string(1)+".gd"):
			var script = load("res://server/commands/"+args[0].get_string(1)+".gd").new()
			# Get the args ready
			var actualCommand = args[0].get_string(1)
			args.pop_front()
			var actualArgs = []
			for arg in args:
				var temp = arg.get_string(1)
				# Remove quotation marks
				if (temp.begins_with("\"") or temp.begins_with("\'")) and (temp.ends_with("\"") or temp.ends_with("\'")):
					temp = temp.right(1)
					temp = temp.left(temp.length()-1)
				# Unescape escaped quotation marks
				temp = temp.replace("\\\"","\"").replace("\\'","'")
				# Add the formatted argument to the list
				actualArgs.append(temp)
			# Call the command
			var returnValue = script.call(actualCommand, actualArgs, self)
			print(returnValue)
			# Send the output back
			if returnValue != null:
				connection.put_data((returnValue+"\n").to_utf8())
		else:
			print(args[0].get_string(1) + ": command not found")
			connection.put_data((args[0].get_string(1) + ": command not found\n").to_utf8())

func initWorld(worldname):
	var scene = load("res://scenes/worlds/"+worldname+".tscn")
	var scene_instance = scene.instance()
	scene_instance.set_name(worldname)
	addSceneToGroup(scene_instance, worldname)
	get_node("/root/MainServer/").add_child(scene_instance)
	# Add YSorts
	var ysort = YSort.new()
	ysort.set_name("players")
	get_node("/root/MainServer/"+worldname+"/Entities").add_child(ysort)
	ysort = YSort.new()
	ysort.set_name("projectiles")
	get_node("/root/MainServer/"+worldname+"/Entities").add_child(ysort)
	ysort = YSort.new()
	ysort.set_name("npc")
	get_node("/root/MainServer/"+worldname+"/Entities").add_child(ysort)
	worlds[worldname] = {"players" : {}, "bags" : {}, "enemies" : {}, "npc" : {}}
	print(worldname+" created")

func save_player_data(world, id):
	var uuid_hash = player_uuids_and_ids[id]["uuid"]
	var char_id = player_uuids_and_ids[id]["id"]
	var newData = worlds[world].players[id].stats
	newData['inventory'] = worlds[world].players[id].inventory
	# Read old data
	var file = File.new()
	file.open("user://serverData/accounts/"+uuid_hash+"/data.json", file.READ)
	var text = file.get_as_text()
	file.close()
	var data = parse_json(text)
	data['chars'][char_id] = newData
	# Write the new data
	file = File.new()
	file.open("user://serverData/accounts/"+uuid_hash+"/data.json", File.WRITE)
	file.store_line(JSON.print(data))
	file.close()

func checkIfClipping(node : KinematicBody2D, a : Vector2, b : Vector2):
	# calculate the relative vector
	var rel_vec = b-a
	# Check if there was any movement at all
	if rel_vec.length() == 0:
		return false
	# check if anything is in the way
	var a_transform = Transform2D()
	a_transform.origin = a
	if node.test_move(a_transform, rel_vec):
		var failed_pixels = 0
		# Split the movement into individual pixels
		var normalized = rel_vec.normalized()
		var split_count = rel_vec.length()/normalized.length()
		# Check each pixel for collisions
		for i in range(int(floor(split_count))-1):
			var trans = a_transform
			trans.origin += normalized*i
			if node.test_move(trans, normalized*(i+1)):
				# There was a collision
				failed_pixels += 1
		# Last pixel
		var trans = a_transform
		trans.origin += normalized*int(floor(split_count))
		if node.test_move(trans, normalized*(split_count-floor(split_count))):
			# There was a collision
			failed_pixels += 1
		# Now we know how many pixels had collisions
		# If less than 2, it was probably due to a wall corner
		# If more, the player is possibly cheating
		if failed_pixels > 2:
			return true
	return false

func update_last_bag_action_time(world, bag_pos):
	if not last_action_on_bag.has(world):
		last_action_on_bag[world] = {}
	last_action_on_bag[world][bag_pos] = OS.get_unix_time()

func remove_last_bag_action_time(world, bag_pos):
	if last_action_on_bag.has(world) and last_action_on_bag[world].has(bag_pos):
		last_action_on_bag[world].erase(bag_pos)

func item_allowed_in_slot(world, player_id, inv_slot, item_id):
	# Check if it's a special slot
	if int(inv_slot) < 1:
		# Check if the item type is allowed in that special slot
		var item_type = Global.items[item_id].type
		var char_class = worlds[world].players[player_id].stats["class"]
		if Global.item_types[item_type].has("special_slots"):
			if Global.item_types[item_type].special_slots.has(inv_slot):
				if not Global.item_types[item_type].special_slots[inv_slot].has(char_class):
					return false
			else:
				return false
		else:
			return false
		
		# Check individual stat requirements
		var stats = worlds[world].players[player_id].stats
		if Global.items[item_id].has("stat_restrictions"):
			for restriction in Global.items[item_id].stat_restrictions.keys():
				if Global.items[item_id].stat_restrictions[restriction] > stats[restriction]:
					return false
	return true

# # # # # # # # # # # # # #
# OTHER REMOTE FUNCTIONS  #
# # # # # # # # # # # # # #

remote func receive_new_uuid():
	pass
remote func receive_character_data(data):
	pass
remote func answer_is_nickname_free(answer):
	pass
remote func answer_is_uuid_valid(answer):
	pass
remote func receive_world_update(world_name, world_data, number):
	pass
remote func receive_rand_seeds(seeds):
	pass