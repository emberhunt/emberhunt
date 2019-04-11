extends Node

# This is the SERVER's side of networking

const SERVER_PORT = 22122
const MAX_PLAYERS = 10


var init_stats = Global.init_stats


var worlds = {}

var time_start = OS.get_ticks_msec()

onready var bullet_container = get_node("/root/MainServer/projectiles")

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
	
	# Create worlds
	var scene = load("res://scenes/worlds/FortressOfTheDark.tscn")
	var scene_instance = scene.instance()
	scene_instance.set_name("FortressOfTheDark")
	addSceneToGroup(scene_instance, "FortressOfTheDark")
	get_node("/root/MainServer/").add_child(scene_instance)
	worlds['FortressOfTheDark'] = {"players" : {}, "items" : {}, "enemies" : {}}
	print("FortressOfTheDark created")

func _process(delta):

	# Sync the worlds with all players
	for world in worlds.keys():
		for player in worlds[world].players.keys():
			rpc_unreliable_id(int(player), "receive_world_update", world, worlds[world])

# # # # # # # # # # # #
# CONNECTED FUNCTIONS #
# # # # # # # # # # # #

func _player_connected(id):
	print(str(id)+" connected")

func _player_disconnected(id):
	for world in worlds.keys():
		if worlds[world].players.has(id):
			get_node("/root/MainServer/players/" + worlds[world].players[id].nickname).queue_free()
			worlds[world].players.erase(id)
	print(str(id)+" disconnected")

# # # # # # # # # # #
# REMOTE FUNCTIONS  #
# # # # # # # # # # #

remote func register_new_account(nickname):
	print("Received request to register new account from "+str(get_tree().get_rpc_sender_id()))
	if nickname.length() <= 50:
		if isNicknameFree(nickname):
			rpc_id(get_tree().get_rpc_sender_id(), "receive_new_uuid", generateRandomUUID(nickname))
		else:
			rpc_id(get_tree().get_rpc_sender_id(), "receive_new_uuid", false)
	else:
		rpc_id(get_tree().get_rpc_sender_id(), "receive_new_uuid", false)
	print("New account registered")

remote func send_character_data(uuid):
	var uuid_hash = uuid.sha256_text()
	# Check if the UUID is registered
	if not checkIfUuidIsRegistered(uuid_hash):
		# The UUID is not registered yet
		rpc_id(get_tree().get_rpc_sender_id(), "receive_character_data", false)
		return
	# Parse data.json
	var data = getUuidData(uuid_hash)
	# Send the data back
	rpc_id(get_tree().get_rpc_sender_id(), "receive_character_data", data)
	pass

remote func receive_new_character_data(uuid, data):
	var uuid_hash = uuid.sha256_text()
	if checkIfUuidIsRegistered(uuid_hash):
		# Check if the data is valid
		var classes = ["Knight","Berserker","Assassin","Sniper","Hunter","Arsonist","Brand","Herald","Redeemer","Druid"]
		if not (data in classes):
			print("Received invalid new character data")
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
					"max_hp": init_stats[data].max_hp,
					"max_mp": init_stats[data].max_mp,
					"strength": init_stats[data].strength,
					"agility": init_stats[data].agility,
					"magic": init_stats[data].magic,
					"luck": init_stats[data].luck,
					"physical_defense": init_stats[data].physical_defense,
					"magic_defense": init_stats[data].magic_defense
				}
				# Write the new data
				setUuidData(uuid_hash, parsed)
			else:
				print("Received new character data, but the account already has 5 characters")
	else:
		print("Received new character data on an UUID which is not registered")

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
				# Spawn the player
				var scene = preload("res://scenes/otherPlayer.tscn")
				var scene_instance = scene.instance()
				scene_instance.set_name(account_data.nickname)
				scene_instance.add_to_group("player")
				addSceneToGroup(scene_instance, world)
				get_node("/root/MainServer/players").add_child(scene_instance)
				worlds[world].players[get_tree().get_rpc_sender_id()] = {
					"position" : scene_instance.position,
					"stats" : account_data.chars[str(character_id)],
					"nickname" : account_data.nickname,
					"lastUpdate" : OS.get_ticks_msec() - time_start,
					"inventory" : {} # Should be loaded from user://serverData/uuidHASH/data.json
				}

remote func exit_world(world):
	# Check if the world exists
	if world in worlds:
		# Check if the character is in that world
		if get_tree().get_rpc_sender_id() in worlds[world].players:
			# Remove it from the world
			get_node("/root/MainServer/players/" + worlds[world].players[get_tree().get_rpc_sender_id()].nickname).queue_free()
			worlds[world].players.erase(get_tree().get_rpc_sender_id())

remote func send_position(world, pos):
	var time_now = OS.get_ticks_msec()
	# Check if the world exists
	if world in worlds:
		# Check if the character is in that world
		if get_tree().get_rpc_sender_id() in worlds[world].players:
			# Validate if the position is legal
			var node = get_node("/root/MainServer/players/" + worlds[world].players[get_tree().get_rpc_sender_id()].nickname)
			if not node.test_move(node.transform, pos-node.position): # No collisions
				# Check the speed
				var maxLegalSpeed = worlds[world].players[get_tree().get_rpc_sender_id()].stats.agility+25
				var timeElapsed = ((time_now - time_start)-worlds[world].players[get_tree().get_rpc_sender_id()].lastUpdate)/1000.0
				var maxLegalDistance = maxLegalSpeed*timeElapsed
				var traveledDistance = (pos-node.position).length()
				# Check if it traveled more than we allow
				if traveledDistance <= maxLegalDistance:
					# Check if the player is not trying to teleport
					if traveledDistance > 25:
						var motion = pos-node.position
						var newMotion = Vector2(motion.x*(25/traveledDistance), motion.y*(25/traveledDistance))
						pos = node.position+newMotion
					# Update player's position
					node.position = pos
					worlds[world].players[get_tree().get_rpc_sender_id()].position = node.position
					worlds[world].players[get_tree().get_rpc_sender_id()].lastUpdate = time_now - time_start

remote func shoot_bullets(world, path_to_scene, bullet_rotation, stats):
	# Check if the world exists
	if world in worlds:
		# Check if the character is in that world
		if get_tree().get_rpc_sender_id() in worlds[world].players:
			# Check if the player should be able to shoot:
			#
			
			# Shoot
			var extra_bullets = 0																				# 
			var extra_bullet_range = range(stats.bullet_count_random.x,stats.bullet_count_random.y+1)			# \
			if len(extra_bullet_range) != 0:																	#	calculate random_bullet_count
				extra_bullets = extra_bullet_range[randi()%len(extra_bullet_range)]								# /
			
			var rotation_step = -1																				# \
			if stats.bullet_spread != 0 and stats.bullet_count + extra_bullets > 1:								#	calculate spread step based on bullet_count and bullet_spread
				rotation_step = float(stats.bullet_spread) / float(stats.bullet_count+extra_bullets)			# /
			
			for bullet_number in range(stats.bullet_count+extra_bullets): 													# for each bullet do:
				var new_bullet = load(path_to_scene).instance() 																		# instance new bullet
				var s_bullet_rotation = bullet_rotation 																					# set base rotation to weapon rotation
				if rotation_step != -1:																							# if there is a fixed spread step
					bullet_rotation += (stats.bullet_count+extra_bullets)/PI * rotation_step*-1 + bullet_number * rotation_step 						# spread the bullets according to the calculated rotation step
				if stats.bullet_spread_random != 0: 																			# if there is a random spread
					bullet_rotation += rand_range(float(stats.bullet_spread_random)/2*-1,float(stats.bullet_spread_random)/2) 		# randomly spread each bullet between -0.5*bullet_spread_random to 0.5*bullet_spread_random radians
						
				new_bullet._ini(stats,worlds[world].players[get_tree().get_rpc_sender_id()].position,bullet_rotation) 															# initialise new bullet, see default_bullet.gd
				new_bullet.add_to_group(world)
				bullet_container.add_child(new_bullet) 																		# add bullet to the bullet container
			rpc_all_in_world(world, "shoot_bullets", [world, path_to_scene, bullet_rotation, stats, worlds[world].players[get_tree().get_rpc_sender_id()].position], [get_tree().get_rpc_sender_id()])

remote func pickup_item(world, item_id, quantity):
	# Check if the world exists
	if world in worlds:
		# Check if the character is in that world
		if get_tree().get_rpc_sender_id() in worlds[world].players:
			# Check if that item exists
			if item_id in worlds[world].items:
				# Check if enough of it is there
				if quantity <= worlds[world].items[item_id].quantity:
					# Check if the player should be able to pick it up
					# with area2D or something, also check if they have
					# enough space in their inventory
					print("item pickup request")
					# Pick it up
					#worlds[world].players[get_tree().get_rpc_sender_id()].inventory[slot] = {"item_id" : item_id, "quantity" : quantity}

remote func ask_to_pickup_item(uuid, world, itemName, itemId, amount):
	DebugConsole.warn("Got asked from %s to pickup %s %s" % [str(uuid), str(itemName), str(amount)])

	rpc_id(uuid, "pickup_item", world, itemName, itemId, amount)
	rpc("remove_pickup_item", world, itemName)

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
				# There's probably a better way to do this, but I'm not a pro
				# And I couldn't find anything on the internet
				if args.size() == 0:
					rpc_id(player_id, function_name)
				elif args.size() == 1:
					rpc_id(player_id, function_name, args[0])
				elif args.size() == 2:
					rpc_id(player_id, function_name, args[0], args[1])
				elif args.size() == 3:
					rpc_id(player_id, function_name, args[0], args[1],
						args[2])
				elif args.size() == 4:
					rpc_id(player_id, function_name, args[0], args[1],
						args[2], args[3])
				elif args.size() == 5:
					rpc_id(player_id, function_name, args[0], args[1],
						args[2], args[3], args[4])
				elif args.size() == 6:
					rpc_id(player_id, function_name, args[0], args[1],
						args[2], args[3], args[4], args[5])
				elif args.size() == 7:
					rpc_id(player_id, function_name, args[0], args[1],
						args[2], args[3], args[4], args[5], args[6])
				elif args.size() == 8:
					rpc_id(player_id, function_name, args[0], args[1],
						args[2], args[3], args[4], args[5], args[6],
						args[7])
				elif args.size() == 9:
					rpc_id(player_id, function_name, args[0], args[1],
						args[2], args[3], args[4], args[5], args[6],
						args[7], args[8])
				elif args.size() == 10:
					rpc_id(player_id, function_name, args[0], args[1],
						args[2], args[3], args[4], args[5], args[6],
						args[7], args[8], args[9])

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
remote func receive_world_update(world_name, world_data):
	pass