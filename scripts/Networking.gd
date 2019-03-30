extends Node

# This is the CLIENT's side of networking

const SERVER_IP = "192.168.1.169"
const SERVER_PORT = 22122

func _ready():
	# Initialize client
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(SERVER_IP, SERVER_PORT)
	get_tree().set_network_peer(peer)
	get_tree().set_meta("network_peer", peer)
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

# # # # # # # # # # # #
# CONNECTED FUNCTIONS #
# # # # # # # # # # # #

func _player_connected(id):
	pass

func _player_disconnected(id):
	pass

func _server_disconnected():
	
	pass # Server kicked us; show error and abort.

func _connected_fail():
	
	pass # Could not even connect to server; abort.

func _connected_ok():
	print("Connected to the server")
	# Check if I already have an UUID assigned
	if not Global.UUID: # I don't
		# Ask player for nickname or UUID
		var scene = load("res://scenes/RequestForNickname.tscn")
		var scene_instance = scene.instance()
		scene_instance.set_name("RequestForNickname")
		get_node("/root/").add_child(scene_instance)
	else:
		# Request for my character data
		requestServerForMyCharacterData()

# # # # # # # # # # #
# REMOTE FUNCTIONS  #
# # # # # # # # # # #

remote func receive_new_uuid(uuid):
	# Make sure the data is sent by server
	if get_tree().get_rpc_sender_id() == 1:
		# Check if I asked for an UUID
		if not Global.UUID: # We did
			Global.UUID = uuid
			Global.saveGame()
			# Now I request for my character data
			requestServerForMyCharacterData()
		else:
			print("Didn't ask for a new UUID but still received one")

remote func receive_character_data(data):
	# Check if it was sent by the server
	if get_tree().get_rpc_sender_id() == 1:
		# Check whether they have my UUID registered
		if typeof(data) == TYPE_BOOL:
			if data == false:
				# My UUID is not registered on the servers
				print("Server says that they don't have my UUID registered")
			else:
				# We should never get TRUE as data
				print("Unexpected character data (TRUE); scripts/Networking.gd:receive_character_data()")
		else:
			# Store the data in Global.gd
			Global.charactersData = data.chars
			Global.nickname = data.nickname
			if get_tree().get_current_scene().get_name() == "MainMenu":
				get_node("/root/MainMenu/Label").set_text(data.nickname)

remote func answer_is_nickname_free(answer):
	# Check if it was sent by the server
	if get_tree().get_rpc_sender_id() == 1:
		get_node("/root/RequestForNickname").receivedAnswerIfNicknameIsFree(answer)

remote func answer_is_uuid_valid(answer):
	# Check if it was sent by the server
	if get_tree().get_rpc_sender_id() == 1:
		get_node("/root/RequestForNickname").receivedAnswerIfUUIDIsValid(answer)

remote func receive_world_update(world_name, world_data):
	# Check if it was sent by the server and if im still in that world
	if get_tree().get_rpc_sender_id() == 1 and world_name == get_tree().get_current_scene().get_name():
		var selfPlayer = get_node("/root/"+get_tree().get_current_scene().get_name()+"/YSort/player")
		# Sync position with server
		# Check if anything is in the way
		if not selfPlayer.test_move(selfPlayer.transform, world_data.players[get_tree().get_network_unique_id()].position-selfPlayer.position):
			selfPlayer.move_and_slide( world_data.players[get_tree().get_network_unique_id()].position-selfPlayer.position )
		else:
			selfPlayer.position = world_data.players[get_tree().get_network_unique_id()].position
		# Update all other players
		for player in world_data.players.keys():
			if player == get_tree().get_network_unique_id():
				continue
			player = world_data.players[player]
			if not get_node("/root/"+get_tree().get_current_scene().get_name()).has_node("players"):
				# There's no PLAYERS node yet
				var node = YSort.new()
				node.set_name("players")
				get_node("/root/"+get_tree().get_current_scene().get_name()).add_child(node)
			# Check if there's that player in our world
			if not get_node("/root/"+get_tree().get_current_scene().get_name()+"/players").has_node(player.nickname):
				# That player is not in our world yet
				var scene = preload("res://scenes/otherPlayer.tscn")
				var scene_instance = scene.instance()
				scene_instance.set_name(player.nickname)
				scene_instance.add_to_group("player")
				get_node("/root/"+get_tree().get_current_scene().get_name()+"/players").add_child(scene_instance)
			# Sync position
			var playernode = get_node("/root/"+get_tree().get_current_scene().get_name()+"/players/"+player.nickname)
			playernode.position = player.position
		# Update all enemies
		#
		# Update all npcs
		#
		# Update all items
		#
		# Update all projectiles
		#
		
		# Check if any nodes got removed
		# Players
		if get_node("/root/"+get_tree().get_current_scene().get_name()).has_node("players"):
			for player in get_node("/root/"+get_tree().get_current_scene().get_name()+"/players").get_children():
				var exists = false
				for playerdata in world_data.players.values():
					if player.get_name() == playerdata.nickname:
						exists = true
				if not exists:
					get_node("/root/"+get_tree().get_current_scene().get_name()+"/players/"+player.get_name()).queue_free()

remote func shoot_bullets(world, path_to_scene, bullet_rotation, stats, shooter_position):
	# Check if it was sent by the server and if im still in that world
	if get_tree().get_rpc_sender_id() == 1 and world == get_tree().get_current_scene().get_name():
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
					
			new_bullet._ini(stats,shooter_position,bullet_rotation) 															# initialise new bullet, see default_bullet.gd
			get_node("/root/"+world+"/bullet_container").add_child(new_bullet) 																		# add bullet to the bullet container

# # # # # # # # # # #
# NORMAL FUNCTIONS  #
# # # # # # # # # # #

func requestServerForMyCharacterData():
	# Send RPC to server
	rpc_id(1, "send_character_data", Global.UUID)

func sendServeNewCharacterData(data):
	rpc_id(1, "receive_new_character_data", Global.UUID, data)

func askServerIfThisNicknameIsFree(nickname):
	rpc_id(1, "check_if_nickname_is_free", nickname)

func registerAccount(nickname):
	rpc_id(1, "register_new_account", nickname)

func askServerIfThisUUIDIsValid(uuid):
	rpc_id(1, "check_if_uuid_exists", uuid)

func requestToJoinWorld(world_name, charID):
	rpc_id(1, "join_world", Global.UUID, charID, world_name)

func sendPosition(pos):
	rpc_unreliable_id(1, "send_position", get_tree().get_current_scene().get_name(), pos)

func exitWorld():
	rpc_id(1, "exit_world", get_tree().get_current_scene().get_name())

func shootBullets(path_to_scene, bullet_rotation, stats):
	rpc_id(1, "shoot_bullets", get_tree().get_current_scene().get_name(), path_to_scene, bullet_rotation, stats)

func askServerToPickUpItem(item_id, quantity, slot):
	rpc_id(1, "pickup_item", get_tree().get_current_scene().get_name(), item_id, quantity, slot)

# # # # # # # # # # # # # #
# OTHER REMOTE FUNCTIONS  #
# # # # # # # # # # # # # #

remote func register_new_account(nickname):
	pass
remote func send_character_data(uuid):
	pass
remote func receive_new_character_data(uuid, data):
	pass
remote func check_if_nickname_is_free(nickname):
	pass
remote func check_if_uuid_exists(uuid):
	pass
remote func join_world(uuid, character_id, world):
	pass
remote func send_input(world, input):
	pass
remote func exit_world(world):
	pass
remote func pickup_item(world, item_id, quantity, slot):
	pass