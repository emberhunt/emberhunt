extends Node

# This is the CLIENT's side of networking

const SERVER_IP = "192.168.1.144"
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
		var selfPlayer = get_node("/root/"+get_tree().get_current_scene().get_name()+"/player/body")
		# Sync position with server
		selfPlayer.position = world_data.players[get_tree().get_network_unique_id()].position

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