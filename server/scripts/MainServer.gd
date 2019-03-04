extends Node

# This is the SERVER's side of networking

const SERVER_PORT = 22122
const MAX_PLAYERS = 10


func _ready():
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

remote func register_new_account():
	print("Received request to register new account from "+str(get_tree().get_rpc_sender_id()))
	rpc_id(get_tree().get_rpc_sender_id(), "receive_new_uuid", generateRandomUUID())
	print("New account registered")

remote func send_character_data(uuid):
	# Get path to UUID's data.json
	var path = getPathToUuid(uuid)
	# Check if the UUID is registered
	if not checkIfUuidIsRegistered(uuid):
		# The UUID is not registered yet
		rpc_id(get_tree().get_rpc_sender_id(), "receive_character_data", false)
		return
	# Parse data.json
	var file = File.new()
	file.open(path+"/data.json", file.READ)
	var text = file.get_as_text()
	var data = parse_json(text)
	file.close()
	# Send the data back
	rpc_id(get_tree().get_rpc_sender_id(), "receive_character_data", data)
	pass

remote func receive_new_character_data(uuid, data):
	if checkIfUuidIsRegistered(uuid):
		# Check if the data is valid
		var classes = ["Knight","Berserker","Assasin","Sniper","Hunter","Arsonist","Brand","Herald","Redeemer","Druid"]
		if not (data in classes):
			print("Received invalid new character data")
		else:
			# Register the new character
			var path = getPathToUuid(uuid)
			# Parse data.json
			var file = File.new()
			file.open(path+"/data.json", file.READ)
			var text = file.get_as_text()
			var parsed = parse_json(text)
			file.close()
			# Add the new data
			parsed.chars[parsed.chars.size()] = {"class":data,"level":1}
			# Write the new data
			file = File.new()
			file.open(path+"/data.json", file.WRITE)
			file.store_line(JSON.print(parsed))
			file.close()
	else:
		print("Received new character data on an UUID which is not registered")
# # # # # # # # # # #
# NORMAL FUNCTIONS  #
# # # # # # # # # # #

func generateRandomUUID():
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
	var path = "user://existingUUIDS"
	var dirList = []
	# Generate random UUID
	for i in range(23):
		randomize()
		var x = intToStr[randi()%62]
		uuid = uuid+str(x)
		path = path+"/"+str(x)
		dirList.append(str(x))
	# check if the uuid is already taken
	var dir = Directory.new()
	if dir.dir_exists(path):
		return generateRandomUUID()
	# continue if it's not
	dir.open("user://existingUUIDS")
	# Create the directory
	var tempPath = "user://existingUUIDS/"
	for i in range(23):
		dir.make_dir(dirList[i])
		dir.open(tempPath+dirList[i])
		tempPath = tempPath+dirList[i]+"/"
	# Create data.json to store account's data
	var file = File.new()
	if file.open(path+"/data.json", File.WRITE) != 0:
		print("Error creating file "+path+"/data.json")
		return
	# Data stored in data.json
	var data = {
		"chars" : {}
	}
	file.store_line(JSON.print(data))
	file.close()
	return uuid

func checkIfUuidIsRegistered(uuid):
	# Get path to UUID's data.json
	var path = "user://existingUUIDS"
	for i in range(uuid.length()):
		path = path+"/"+str(uuid[i])
	# Check if the UUID is registered
	var dir = Directory.new()
	if not dir.dir_exists(path):
		# The UUID is not registered yet
		return false
	return true

func getPathToUuid(uuid):
	var path = "user://existingUUIDS"
	for i in range(uuid.length()):
		path = path+"/"+str(uuid[i])
	return path
# # # # # # # # # # # # # #
# OTHER REMOTE FUNCTIONS  #
# # # # # # # # # # # # # #

remote func receive_new_uuid():
	pass
remote func receive_character_data(data):
	pass