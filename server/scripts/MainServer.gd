extends Node

# This is the SERVER's side of networking

const SERVER_PORT = 22122
const MAX_PLAYERS = 10


var init_stats = Global.init_stats

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

# # # # # # # # # # # #
# CONNECTED FUNCTIONS #
# # # # # # # # # # # #

func _player_connected(id):
	print(str(id)+" connected")

func _player_disconnected(id):
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