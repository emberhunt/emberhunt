func give(args = [], mainServer = null) -> String:
	if mainServer == null:
		return "Instance of MainServer.gd is invalid"
	if args.size() == 0:
		return "Please specify an ID, because I need to know who to give the item to"
	if args.size() == 1:
		return "Please specify an item identificator, I need to know what item to give"
	# Check if a player with specified ID is playing right now
	var all_players = {}
	for world in mainServer.worlds.keys():
		for player_id in mainServer.worlds[world].players.keys():
			all_players[player_id] = world
	if not (int(args[0]) in all_players.keys()):
		return "Nobody is playing with ID "+args[0]+" right now..."
	# Check if an item with the specified it exists
	if not (args[1] in Global.items.keys()):
		return "No item with identificator "+args[1]+" exists."
	# Define how many items to add
	var quantity = 1 # Default
	if Global.item_types[ Global.items[args[1]].type ].stack_size == 1:
		quantity = ""
	elif args.size() == 3:
		if int(args[2]) > 0:
			if int(args[2]) <= Global.item_types[ Global.items[args[1]].type ].stack_size:
				quantity = int(args[2])
			else:
				return args[1]+"'s stack size is "+str(Global.item_types[ Global.items[args[1]].type ].stack_size)+"."
		else:
			return "Can not give negative amount of items ("+str(int(args[2]))+")"
	
	var player_data = mainServer.worlds[all_players[int(args[0])]].players[int(args[0])].duplicate(true)
	
	var player_inventory = player_data.inventory
	# Remove special slots, because they don't count
	if player_inventory.has("0"):
		player_inventory.erase("0")
	if player_inventory.has("1"):
		player_inventory.erase("1")
	if player_inventory.has("2"):
		player_inventory.erase("2")
	if player_inventory.has("3"):
		player_inventory.erase("3")
	# Check if the player has enough slots
	if player_data.stats.level+16 == player_inventory.size():
		return player_data.nickname + " doesn't have any free slots."
	# Get the slotID of first free slot
	var slotID = -1
	for potential_slot_id in range(player_data.stats.level+16):
		if not player_inventory.has(str(potential_slot_id+4)):
			# Found the free slot
			slotID = str(potential_slot_id+4)
			break
	print(slotID)
	if slotID == -1:
		return "Internal error"
	# Add the item
	mainServer.worlds[all_players[int(args[0])]].players[int(args[0])].inventory[slotID] = \
		{
			"item_id" : args[1],
			"quantity" : quantity
		}
	# Save
	mainServer.save_player_data(all_players[int(args[0])], int(args[0]))
	return "Gave "+args[0]+" ("+player_data.nickname \
		+") "+( str(quantity)+" " if quantity != "" else "")+args[1]