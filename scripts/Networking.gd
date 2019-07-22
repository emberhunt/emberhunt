# Copyright 2019 Emberhunt Team
# https://github.com/emberhunt
# Licensed under the GNU General Public License v3.0 or later
# SPDX-License-Identifier: GPL-3.0-or-later

extends Node

# This is the CLIENT's side of networking

const SERVER_IP = "emberhunt.cnidarias.net"
const SERVER_PORT = 22122

var connected = false

var rand_seeds = []
var rand_seeds_requested_not_received = 0

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


func _process(delta):
	if connected:
		# Check if we need to request more rand_seeds
		if rand_seeds.size()+rand_seeds_requested_not_received < 100:
			# Hell yeah we do
			var to_request = 100-rand_seeds.size()-rand_seeds_requested_not_received
			rpc_id(1, "request_rand_seeds", to_request)
			rand_seeds_requested_not_received += to_request

# # # # # # # # # # # #
# CONNECTED FUNCTIONS #
# # # # # # # # # # # #

func _player_connected(id):
	pass

func _player_disconnected(id):
	pass

func _server_disconnected():
	connected = false
	pass # Server kicked us; show error and abort.

func _connected_fail():
	connected = false
	pass # Could not even connect to server; abort.

func _connected_ok():
	connected = true
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
		# Save the dictionary for other uses later
		Global.world_data = world_data.duplicate()
		# update characters data
		Global.charactersData[Global.charID] = world_data.players[get_tree().get_network_unique_id()].stats
		Global.charactersData[Global.charID].inventory = world_data.players[get_tree().get_network_unique_id()].inventory.duplicate()
		var selfPlayer = get_node("/root/"+get_tree().get_current_scene().get_name()+"/Entities/player")
		# Update inventory gui if we're viewing it
		if get_node("/root/"+get_tree().get_current_scene().get_name()+"/GUI/CanvasLayer").has_node("Inventory"):
			get_node("/root/"+get_tree().get_current_scene().get_name()+"/GUI/CanvasLayer/Inventory").update_gui()
		if get_node("/root/"+get_tree().get_current_scene().get_name()+"/GUI/CanvasLayer").has_node("InventoryAndBag"):
			get_node("/root/"+get_tree().get_current_scene().get_name()+"/GUI/CanvasLayer/InventoryAndBag").update_gui()
		# Sync position with server
		# If anything is in the way, just teleport there
		if not selfPlayer.test_move(selfPlayer.transform, world_data.players[get_tree().get_network_unique_id()].position-selfPlayer.position) \
		and (world_data.players[get_tree().get_network_unique_id()].position-selfPlayer.position).length()<10:
			selfPlayer.move_and_slide( world_data.players[get_tree().get_network_unique_id()].position-selfPlayer.position )
		else:
			selfPlayer.position = world_data.players[get_tree().get_network_unique_id()].position
		# Update all other players
		for playerID in world_data.players.keys():
			if playerID == get_tree().get_network_unique_id():
				continue
			var player = world_data.players[playerID]
			# Check if there's that player in our world
			if not get_node("/root/"+get_tree().get_current_scene().get_name()+"/Entities/players").has_node(str(playerID)):
				# That player is not in our world yet
				var scene = preload("res://scenes/otherPlayer.tscn")
				var scene_instance = scene.instance()
				scene_instance.set_name(str(playerID))
				scene_instance.add_to_group("player")
				scene_instance.enabled = true
				# Disable collisions
				scene_instance.get_node("CollisionShape2D").disabled = true
				scene_instance.get_node("nickname").set_text(world_data.players[playerID].nickname)
				get_node("/root/"+get_tree().get_current_scene().get_name()+"/Entities/players").add_child(scene_instance)
			# Sync position
			var playernode = get_node("/root/"+get_tree().get_current_scene().get_name()+"/Entities/players/"+str(playerID))
			playernode.speed = world_data.players[playerID].stats.agility+25
			if (playernode.position-player.position).length() < 25:
				playernode.move(player.position)
			else:
				playernode.position = player.position
		# Update all enemies
		#
		# Update all npcs
		#
		
		# Update all bags
		var processed_bags = []
		for local_bag in get_node("/root/"+get_tree().get_current_scene().get_name()+"/Entities/bags").get_children():
			# Add the processed new world_data bag to the processed bags list
			processed_bags.append(local_bag.position)
			# Check if that bag exists in the new world data
			if not (local_bag.position in world_data.bags.keys()):
				# Nope, we should delete it
				local_bag.queue_free()
		# Now if there are any unprocessed bags left, that means they're new and we need to add them
		var unprocessed_bags = subtract_array(world_data.bags.keys(), processed_bags)
		for new_bag in unprocessed_bags:
			# Make sure it's not a private bag
			if (world_data.bags[new_bag].has("player") and world_data.bags[new_bag].player == get_tree().get_network_unique_id()) \
			or not world_data.bags[new_bag].has("player"):
				# Add the bag
				var scene_instance = preload("res://scenes/inventory/Bag.tscn").instance()
				scene_instance.position = new_bag
				get_node("/root/"+get_tree().get_current_scene().get_name()+"/Entities/bags").add_child(scene_instance)
		
		
		# Check if any nodes got removed
		# Players
		for player in get_node("/root/"+get_tree().get_current_scene().get_name()+"/Entities/players").get_children():
			var exists = false
			for playerdata in world_data.players.keys():
				if player.get_name() == str(playerdata):
					exists = true
					break
			if not exists:
				get_node("/root/"+get_tree().get_current_scene().get_name()+"/Entities/players/"+player.get_name()).queue_free()

remote func shoot_bullets(world, bullets, attack_sound, shooter, shooter_name, pos):
	# Check if it was sent by the server and if im still in that world
	if get_tree().get_rpc_sender_id() == 1 and world == get_tree().get_current_scene().get_name():
		# Check if the bullets weren't shot by myself, because if they were, we don't want to spawn the same bullets again!
		if shooter == "player" && shooter_name == str(get_tree().get_network_unique_id()):
			return
		if attack_sound != "":
			SoundPlayer.play(SoundPlayer.loaded_sounds[attack_sound],-10)
		
		for bullet in bullets:
			# Spawn the bullet
			var new_bullet = Global.loaded_bullets[bullets[0].scene].instance()
			new_bullet._ini(bullet, shooter, shooter_name, pos)
			get_node("/root/"+world+"/Entities/projectiles").add_child(new_bullet)

remote func receive_rand_seeds(seeds):
	# Check if it was sent by the server
	if get_tree().get_rpc_sender_id() == 1:
		rand_seeds += seeds
		rand_seeds_requested_not_received -= seeds.size()

# # # # # # # # # # #
# NORMAL FUNCTIONS  #
# # # # # # # # # # #

func requestServerForMyCharacterData():
	# Send RPC to server
	if connected:
		rpc_id(1, "send_character_data", Global.UUID)

func sendServeNewCharacterData(data):
	# Check if we are connected to the server
	if connected:
		rpc_id(1, "receive_new_character_data", Global.UUID, data)

func askServerIfThisNicknameIsFree(nickname):
	# Check if we are connected to the server
	if connected:
		rpc_id(1, "check_if_nickname_is_free", nickname)

func registerAccount(nickname):
	if connected:
		rpc_id(1, "register_new_account", nickname)

func askServerIfThisUUIDIsValid(uuid):
	if connected:
		rpc_id(1, "check_if_uuid_exists", uuid)

func requestToJoinWorld(world_name, charID):
	# Check if we are connected to the server
	if connected:
		rpc_id(1, "join_world", Global.UUID, charID, world_name)

func sendPosition(direction, delta):
	# Check if we are connected to the server
	if connected:
		rpc_id(1, "send_position", get_tree().get_current_scene().get_name(), direction, delta)

func exitWorld():
	# Check if we are connected to the server
	if connected:
		rpc_id(1, "exit_world", get_tree().get_current_scene().get_name())

func shootBullets(rotation):
	# Check if we are connected to the server
	if connected:
		rpc_id(1, "shoot_bullets", get_tree().get_current_scene().get_name(), rotation)

func dropItem(slot, bag_pos, bag_slot, quantity = -1):
	# Check if we are connected to the server
	if connected:
		rpc_id(1, "drop_item", get_tree().get_current_scene().get_name(), slot, bag_pos, bag_slot, quantity)

func pickupItem(bag_pos, bag_slot, inv_slot, quantity = -1):
	# Check if we are connected to the server
	if connected:
		rpc_id(1, "pickup_item", get_tree().get_current_scene().get_name(), bag_pos, bag_slot, inv_slot, quantity)

func changeInventoryLayout(new_layout):
	# Check if we are connected to the server
	if connected:
		rpc_id(1, "change_inventory_layout", get_tree().get_current_scene().get_name(), new_layout)

func changeBagLayout(bag_pos, new_layout):
	# Check if we are connected to the server
	if connected:
		rpc_id(1, "change_bag_layout", get_tree().get_current_scene().get_name(), bag_pos, new_layout)

func swapItem(inv_slot_id, bag_slot_id, bag_pos):
	# Check if we are connected to the server
	if connected:
		rpc_id(1, "swap_item", get_tree().get_current_scene().get_name(), inv_slot_id, bag_slot_id, bag_pos)

func mergeItem(inv_slot_id, bag_slot_id, bag_pos, target_bag : bool):
	# Check if we are connected to the server
	if connected:
		rpc_id(1, "merge_item", get_tree().get_current_scene().get_name(), inv_slot_id, bag_slot_id, bag_pos, target_bag)

func subtract_array(array1, array2):
	var final_array = []
	for item in array1:
		if not (item in array2):
			final_array.append(item)
	return final_array


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
remote func send_position(world, pos, number):
	pass
remote func exit_world(world):
	pass
remote func request_rand_seeds(how_many):
	pass
remote func drop_item(world, slot, bag_pos, bag_slot):
	pass
remote func pickup_item(world, bag_pos, bag_slot, inv_slot):
	pass
remote func change_inventory_layout(world, new_layout):
	pass
remote func change_bag_layout(world, bag_pos, new_layout):
	pass
remote func swap_item(world, inv_slot_id, bag_slot_id, bag_pos):
	pass
remote func merge_item(world, inv_slot_id, bag_slot_id, bag_pos, target_bag):
	pass