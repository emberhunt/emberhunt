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
#			"<player_id>" : [1651652163513525632, -1865653153222222322],

var lastUpdateRPC = {}
var updatesSentToPlayer = {}

var time_start = OS.get_ticks_msec()

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

	# Sync the worlds with all players
	for world in worlds.keys():
		for player in worlds[world].players.keys():
			if int(player) in updatesSentToPlayer.keys():
				updatesSentToPlayer[int(player)] += 1
			else:
				updatesSentToPlayer[int(player)] = 1
			rpc_unreliable_id(int(player), "receive_world_update", world, worlds[world], updatesSentToPlayer[int(player)])

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
	if nickname.length() <= 50:
		if isNicknameFree(nickname):
			var uuid = generateRandomUUID(nickname)
			rpc_id(get_tree().get_rpc_sender_id(), "receive_new_uuid", uuid)
			print("New account registered")
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
					"inventory" : {
						"4": {"item_id":"woodsword","quantity":""}
					}
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
					"lastUpdate" : OS.get_ticks_msec() - time_start,
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

remote func send_position(world, pos, number):
	var time_now = OS.get_ticks_msec()
	# Check if the world exists
	if world in worlds:
		# Check if the character is in that world
		if get_tree().get_rpc_sender_id() in worlds[world].players:
			# Check if this RPC isn't too old
			if get_tree().get_rpc_sender_id() in lastUpdateRPC.keys():
				if lastUpdateRPC[get_tree().get_rpc_sender_id()] > number:
					# We already have a newer send_position RPC from this player
					return
			lastUpdateRPC[get_tree().get_rpc_sender_id()] = number
			# Validate if the position is legal
			var player_node = get_node("/root/MainServer/"+world+"/Entities/players/" + str(get_tree().get_rpc_sender_id()))
			if not player_node.test_move(player_node.transform, pos-player_node.position): # No collisions
				# Check the speed
				var maxLegalSpeed = worlds[world].players[get_tree().get_rpc_sender_id()].stats.agility+25
				var timeElapsed = ((time_now - time_start)-worlds[world].players[get_tree().get_rpc_sender_id()].lastUpdate)/1000.0
				var maxLegalDistance = maxLegalSpeed*timeElapsed
				var traveledDistance = (pos-player_node.position).length()
				# Check if it traveled more than we allow
				if traveledDistance > maxLegalDistance:
					var motion = pos-player_node.position
					var newMotion = Vector2(motion.x*(maxLegalDistance/traveledDistance), motion.y*(maxLegalDistance/traveledDistance))
					pos = player_node.position+newMotion
				# Check if the player is not trying to teleport
				if traveledDistance > 100:
					var motion = pos-player_node.position
					var newMotion = Vector2(motion.x*(50/traveledDistance), motion.y*(50/traveledDistance))
					pos = player_node.position+newMotion
				# Update player's position
				player_node.position = pos
				worlds[world].players[get_tree().get_rpc_sender_id()].position = player_node.position
				worlds[world].players[get_tree().get_rpc_sender_id()].lastUpdate = time_now - time_start

remote func request_rand_seeds(how_many):
	var generator = RandomNumberGenerator.new()
	var seeds = []
	for iteration in range(how_many):
		generator.randomize()
		seeds.append(generator.seed)
	rpc_id(get_tree().get_rpc_sender_id(), "receive_rand_seeds", seeds)
	given_rand_seeds[get_tree().get_rpc_sender_id()] += seeds

remote func shoot_bullets(world, bullets, attack_sound):
	# Check if the world exists
	if world in worlds:
		# Check if the character is in that world
		if get_tree().get_rpc_sender_id() in worlds[world].players:
			# Check if the player should be able to shoot:
			if get_tree().get_rpc_sender_id() in lastShots.keys():
				if (OS.get_ticks_msec() - lastShots[get_tree().get_rpc_sender_id()]) < 1000.0/3-40: # 40ms is tolerated
					return
			# Shoot
			lastShots[get_tree().get_rpc_sender_id()] = OS.get_ticks_msec()
			var spawn_point = worlds[world].players[get_tree().get_rpc_sender_id()].position + Vector2(sin(bullets[0].rotation), -cos(bullets[0].rotation))*5
			for bullet in bullets:
				# Spawn the bullet
				var new_bullet = Global.loaded_bullets[bullet['scene']].instance()
				new_bullet._ini(bullet, "player", str(get_tree().get_rpc_sender_id()), spawn_point)
				get_node("/root/MainServer/"+world+"/Entities/projectiles/").add_child(new_bullet)
			rpc_all_in_world(world, "shoot_bullets", [world, bullets, attack_sound, "player", str(get_tree().get_rpc_sender_id()), spawn_point])

remote func inventory_changes(world, newInventory):
	# Check if the world exists
	if world in worlds:
		# Check if the character is in that world
		if get_tree().get_rpc_sender_id() in worlds[world].players:
			# Validate the inventory changes
			#   Check if any items appeared/disappeared
			#   Check if all slots are in range
			var oldInventory = worlds[world].players[get_tree().get_rpc_sender_id()].inventory.values()
			oldInventory.sort_custom(InventorySorter, "sort")
			var newInventoryKeys = newInventory.keys()
			var newInventoryValues = newInventory.values()
			newInventoryValues.sort_custom(InventorySorter, "sort")
			if str(newInventoryValues) == str(oldInventory) and \
				newInventoryKeys.min() >= 0 and \
				newInventoryKeys.max() < worlds[world].players[get_tree().get_rpc_sender_id()].stats.level+20:
				# The change is valid
				worlds[world].players[get_tree().get_rpc_sender_id()].inventory = newInventory
				# Save
				save_player_data(world, get_tree().get_rpc_sender_id())
			else:
				print("Received inventory_changes RPC with invalid data")

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

# # # # # #
# SORTERS #
# # # # # #

class InventorySorter:
	static func sort(a, b):
		if a["item_id"].length() < b["item_id"].length():
			return true
		return false


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
	ysort.set_name("items")
	get_node("/root/MainServer/"+worldname+"/Entities").add_child(ysort)
	ysort = YSort.new()
	ysort.set_name("npc")
	get_node("/root/MainServer/"+worldname+"/Entities").add_child(ysort)
	worlds[worldname] = {"players" : {}, "items" : {}, "enemies" : {}, "npc" : {}}
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