extends Node2D

const SERVER_IP = "localhost"
const SERVER_PORT = 22122

func _ready():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(SERVER_IP, SERVER_PORT)
	get_tree().set_network_peer(peer)
	get_tree().set_meta("network_peer", peer)
	set_network_master(1)
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	

func _player_connected(id):
	pass

func _player_disconnected(id):
	pass

func _connected_ok():
	# Check if I already have an UUID assigned
	if not Global.UUID: # I don't
		rpc_id(1, "registerNewAccount")
		

remote func receiveNewUUID(uuid):
	# Check if we asked for an UUID
	if not Global.UUID: # We did
		Global.UUID = uuid
		Global.saveGame()
	else:
		print("Didn't ask for a new UUID but still received one")

func _server_disconnected():
	
	pass # Server kicked us; show error and abort.

func _connected_fail():
	
	pass # Could not even connect to server; abort.
