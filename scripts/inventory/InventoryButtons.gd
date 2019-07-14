# Copyright 2019 Emberhunt Team
# https://github.com/emberhunt
# Licensed under the GNU General Public License v3.0 or later
# SPDX-License-Identifier: GPL-3.0-or-later

extends Control

var info_window_open = false

onready var playernode = get_node("/root/"+get_tree().get_current_scene().get_name()+"/Entities/player")

var drop_button_status = "" # Either "drop" or "pickup"

var drop_hold_start = -1

func set_buttons_state():
	for button in get_children():
		button.disabled = get_parent().selected_slot.empty()
		if get_parent().selected_slot.empty():
			button.get_child(0).add_color_override("font_color", ColorN("gray"))
		else:
			button.get_child(0).add_color_override("font_color", ColorN("white"))
	
	if not get_parent().selected_slot.empty():
		# Check the item is meant to be in a special slot, but
		# Is not allowed to be there
		# In which case we will have to grey out the USE button
		var item_id
		if get_parent().selected_slot.in_bag:
			item_id = get_parent().items.bag[get_parent().selected_slot.slot_id].item_id
		else:
			item_id = get_parent().items.inventory[get_parent().selected_slot.slot_id].item_id
		if Global.item_types[ Global.items[item_id].type ].has("special_slots"):
			for slot in Global.item_types[ Global.items[item_id].type ].special_slots.keys():
				if not get_parent().allowed_in_slot(item_id, slot):
					get_node("Use").disabled = true
					get_node("Use").get_child(0).add_color_override("font_color", ColorN("gray"))
		
		# Also check if the item's stat requirements are met
		# If not, also grey out the USE button
		if Global.items[item_id].has("stat_restrictions"):
			for restriction in Global.items[item_id].stat_restrictions.keys():
				if Global.items[item_id].stat_restrictions[restriction] > get_parent().stats[restriction]:
					get_node("Use").disabled = true
					get_node("Use").get_child(0).add_color_override("font_color", ColorN("gray"))
	
	if get_parent().selected_slot.empty():
		get_node("Drop").disabled = true
		get_node("Drop/Label").add_color_override("font_color", ColorN("gray"))
	else:
		# You can't drop an item when it's already in a bag,
		# So if the selected item is in_bag, change it to PICK UP
		if get_parent().selected_slot.in_bag:
			# If the inventory is full we can't pick it up, so disable the button altogether
			var temp_inv = get_parent().items.inventory.duplicate(true)
			# Remove all the special slots because they don't count
			var special_slots = get_parent().special_slots_count
			for special_slot in range(special_slots):
				if temp_inv.has(str(special_slot)):
					temp_inv.erase(str(special_slot))
			
			if temp_inv.size() == Global.charactersData[Global.charID].level+20-special_slots:
				get_node("Drop").disabled = true
				get_node("Drop/Label").add_color_override("font_color", ColorN("gray"))
			else:
				get_node("Drop").disabled = false
				get_node("Drop/Label").add_color_override("font_color", ColorN("white"))
			
			var font = get_node("Drop/Label").get_font("font")
			font.set_size(50)
			get_node("Drop/Label").add_font_override("font", font)
			get_node("Drop/Label").set_text("pick up")
			drop_button_status = "pickup"
		else:
			get_node("Drop").disabled = false
			get_node("Drop/Label").add_color_override("font_color", ColorN("white"))
			var font = get_node("Drop/Label").get_font("font")
			font.set_size(83)
			get_node("Drop/Label").add_font_override("font", font)
			get_node("Drop/Label").set_text("drop")
			drop_button_status = "drop"

func _on_Use_pressed():
	load("res://scripts/inventory/Use.gd").new().call("use", get_parent())

func _on_Info_pressed():
	var scene_instance = preload("res://scenes/inventory/itemInfo.tscn").instance()
	scene_instance.set_name("ItemInfo")
	# Set the text
	var item_id = ""
	if get_parent().selected_slot.in_bag:
		item_id = get_parent().items.bag[get_parent().selected_slot.slot_id].item_id
	else:
		item_id = get_parent().items.inventory[get_parent().selected_slot.slot_id].item_id
	
	var itemData = Global.items[item_id]
	var infoFormatter = preload("res://scripts/inventory/ItemInfoFormatter.gd").new().call("get_formatter", itemData)
	var infoLeft = Global.item_types[Global.items[item_id].type].infoLeft.format(infoFormatter)
	var infoRight = Global.item_types[Global.items[item_id].type].infoRight.format(infoFormatter)
	
	scene_instance.get_node("Control/ItemTitle").set_text(itemData.title)
	scene_instance.get_node("Control/ItemDescription").set_text(itemData.description)
	scene_instance.get_node("Control/ItemType").set_text(itemData.type)
	scene_instance.get_node("Control/ItemInfoLeft").set_text(infoLeft)
	scene_instance.get_node("Control/ItemInfoRight").set_text(infoRight)
	scene_instance.get_node("Control/ItemRarity").set_text("Rarity: "+str(itemData.rarity))
	get_parent().add_child(scene_instance)
	positionInfoWindow(scene_instance, get_parent().selected_slot.node.rect_global_position+Vector2(24,24))
	info_window_open = true

func _ready():
	set_buttons_state()
	# Make sure the font size is 83
	var font = get_node("Drop/Label").get_font("font")
	font.set_size(83)
	get_node("Drop/Label").add_font_override("font", font)

func _input(event):
	if event is InputEventMouseButton and event.pressed and info_window_open:
		get_node("../ItemInfo").queue_free()
		info_window_open = false

func positionInfoWindow(window, pos : Vector2):
	var screensize = get_viewport().size
	var flipX = false
	var flipY = false
	if pos.x >= screensize.x/2.0:
		flipX = true
		pos.x -= window.rect_size.x
	if pos.y >= screensize.y/2.0:
		flipY = true
		pos.y -= window.rect_size.y
	
	if not flipY:
		if pos.y+window.rect_size.y > screensize.y:
			window.rect_global_position.y = screensize.y-window.rect_size.y
		else:
			window.rect_global_position.y = pos.y
	else:
		if pos.y < 0:
			window.rect_global_position.y = 0
		else:
			window.rect_global_position.y = pos.y
	
	if not flipX:
		if pos.x+window.rect_size.x+50 > screensize.x:
			window.rect_global_position.x = screensize.x-window.rect_size.x
		else:
			window.rect_global_position.x = pos.x+50
	else:
		if pos.x-50 < 0:
			window.rect_global_position.x = window.rect_size.x-window.rect_size.x
		else:
			window.rect_global_position.x = pos.x-50
	
	window.get_node("Block").rect_global_position = Vector2(0,0)


func sort_by_distance(a, b):
	return (a-playernode.position).length() < (b-playernode.position).length()

func _on_Drop_button_down():
	if get_parent().selected_slot.in_bag:
		if int(get_parent().items.bag[get_parent().selected_slot.slot_id].quantity)<=1:
			return
	else:
		if int(get_parent().items.inventory[get_parent().selected_slot.slot_id].quantity)<=1:
			return
	drop_hold_start = OS.get_ticks_msec()

func _process(delta):
	if drop_hold_start!=-1:
		if drop_hold_start+500 <= OS.get_ticks_msec():
			drop_hold_start=-1
			# The button was held enough
			# Reset the outline color
			var font = get_node("Drop/Label").get_font("font")
			font.set_outline_color(ColorN("black"))
			get_node("Drop/Label").add_font_override("font", font)
			# Open asker
			var asker = preload("res://scenes/inventory/Asker.tscn").instance()
			get_node("../..").add_child(asker)
			if get_parent().selected_slot.in_bag:
				asker.init("pick up", int(get_parent().items.bag[get_parent().selected_slot.slot_id].quantity), self)
			else:
				asker.init("drop", int(get_parent().items.inventory[get_parent().selected_slot.slot_id].quantity), self)
			return
		# The button is held right now
		# Make the font's outline bigger with time until it is held 1 second
		var font = get_node("Drop/Label").get_font("font")
		var val = (OS.get_ticks_msec()-drop_hold_start)*255/500
		font.set_outline_color(Color8(val,val,val))
		get_node("Drop/Label").add_font_override("font", font)

func _on_Drop_button_up():
	if drop_hold_start+500 > OS.get_ticks_msec() or \
		(get_parent().selected_slot.in_bag and int(get_parent().items.bag[get_parent().selected_slot.slot_id].quantity)<=1) or \
		(not get_parent().selected_slot.in_bag and int(get_parent().items.inventory[get_parent().selected_slot.slot_id].quantity)<=1):
		
		# Reset the outline color
		var font = get_node("Drop/Label").get_font("font")
		font.set_outline_color(ColorN("black"))
		get_node("Drop/Label").add_font_override("font", font)
		drop_hold_start = -1
		# That means it was just normally pressed, not held
		if drop_button_status == "pickup":
			# Pick up the item
			pickup()
		else:
			# Drop the item
			drop()

func asker_done(quantity):
	if get_parent().selected_slot.in_bag:
		# Pick up x items
		
		# If x is max, then just pick up everything
		if quantity==int(get_parent().items.bag[get_parent().selected_slot.slot_id].quantity):
			pickup()
			return
		
		# Find the first free slot in the inventory
		var slotID = ""
		for slot in range(Global.charactersData[Global.charID].level+20-get_parent().special_slots_count):
			if not get_parent().items.inventory.has(str(slot+get_parent().special_slots_count)):
				slotID = str(slot+get_parent().special_slots_count)
				break
		
		# If there are no free slots, don't pick up the item, and disable the pickup button
		if slotID == "":
			get_node("Drop/Label").disabled = true
			get_node("Drop/Label").add_color_override("font_color", Color8(102,102,102))
			return
		
		var item_node = get_parent().items.bag[get_parent().selected_slot.slot_id].node
		
		# Change the selected slot's quantity and later add a new item in the inventory
		var newQuantity = get_parent().items.bag[get_parent().selected_slot.slot_id].quantity - quantity
		item_node.get_child(0).set_text(str(newQuantity))
		get_parent().items.bag[get_parent().selected_slot.slot_id].quantity = newQuantity
		Global.world_data.bags[get_parent().bag_pos].items[get_parent().selected_slot.slot_id].quantity = newQuantity
		
		# Add the new item to inventory
		var item = preload("res://scenes/inventory/Item.tscn").instance()
		# Set the item's sprite and quantity
		item.texture_normal = item_node.texture_normal
		item.get_child(0).set_text(str(quantity))
		item.connect("button_down", get_parent(), "item_pressed", [slotID, false])
		
		# Position the item on the slot
		item.set_name(slotID)
		get_node("../InventoryGrid/Items").add_child(item)
		item.rect_position.x = ((int(slotID)-get_parent().special_slots_count)%get_node("../InventoryGrid/Slots").columns)*76 + 9
		item.rect_position.y = int(float(int(slotID)-get_parent().special_slots_count)/float(get_node("../InventoryGrid/Slots").columns))*76 + 9
		get_parent().items.inventory[slotID] = {
			"item_id" : get_parent().items.bag[get_parent().selected_slot.slot_id].item_id,
			"quantity": quantity,
			"node" : item
		}
		Global.charactersData[Global.charID].inventory[slotID] = get_parent().items.inventory[slotID].duplicate(true)
		Global.charactersData[Global.charID].inventory[slotID].erase("node")
		
		# Inform the server
		Networking.pickupItem(get_parent().bag_pos, get_parent().selected_slot.slot_id, slotID, quantity)
		
		set_buttons_state()
	else:
		# Drop x items
		
		# If x is max, then just drop everything
		if quantity==int(get_parent().items.inventory[get_parent().selected_slot.slot_id].quantity):
			drop()
			return
		
		# Check if there's a bag nearby to which to drop the items to
		var bags = []
		for bag_pos in Global.world_data.bags.keys():
			# Check if that bag is not private
			if not Global.world_data.bags[bag_pos].has("player") or ( Global.world_data.bags[bag_pos].has("player") and Global.world_data.bags[bag_pos].player==get_tree().get_network_unique_id() ):
				bags.append(bag_pos)
		# Sort the bags by distance from the player
		bags.sort_custom(self, "sort_by_distance")
		
		# Loop throught the bags to find the nearest not-full bag that is in range
		var bag = null
		for bag_pos in bags:
			if (bag_pos-playernode.position).length()<=12:
				# Good, it's in range
				if Global.world_data.bags[bag_pos].items.size() < 20:
					# Very good, it's not full
					bag = bag_pos
					break
			else:
				break
		
		# Check if we found a valid bag
		if bag != null:
			# Hurray! There's a bag close enough for us to drop the items there!
			
			# Add the items to the bag
			# Get the slot_id of the first free slot
			var slotID
			for i in range(20):
				if not Global.world_data.bags[bag].items.has(str(i)):
					slotID = str(i)
					break
			
			var item_node = get_parent().items.inventory[get_parent().selected_slot.slot_id].node
			
			# Change the selected item's quantity
			var newQuantity = get_parent().items.inventory[get_parent().selected_slot.slot_id].quantity - quantity
			item_node.get_child(0).set_text(str(newQuantity))
			get_parent().items.inventory[get_parent().selected_slot.slot_id].quantity = newQuantity
			Global.charactersData[Global.charID].inventory[get_parent().selected_slot.slot_id].quantity = newQuantity
			
			
			# If we're viewing the bag, add the other item node to bag
			if get_parent().viewing_bag and get_parent().bag_pos == bag:
				# Add the new item to bag
				var item = preload("res://scenes/inventory/Item.tscn").instance()
				# Set the item's sprite and quantity
				item.texture_normal = item_node.texture_normal
				item.get_child(0).set_text(str(quantity))
				item.connect("button_down", get_parent(), "item_pressed", [slotID, true])
				item.set_name(slotID)
				get_node("../BagGrid/Items").add_child(item)
				item.rect_position.x = (int(slotID)%get_node("../BagGrid/Slots").columns)*76 + 9
				item.rect_position.y = int((float(slotID))/float(get_node("../BagGrid/Slots").columns))*76 + 9
			
				get_parent().items.bag[slotID] = {
					"item_id" : get_parent().items.inventory[get_parent().selected_slot.slot_id].item_id,
					"quantity": quantity,
					"node" : item
				}
			
			Global.world_data.bags[bag].items[slotID] = {
				"item_id" : get_parent().items.inventory[get_parent().selected_slot.slot_id].item_id,
				"quantity": quantity
			}
			
			# Inform the server
			Networking.dropItem(get_parent().selected_slot.slot_id, bag, slotID, quantity)
			
			set_buttons_state()
			
			return
		# There's no bag close enough, we will have to add one
		
		var bag_dropping_pos = get_parent().bag_pos if get_parent().viewing_bag else playernode.position
		
		# If there's already a bag in range, but its full
		# Or if there's a private bag in the exact same position
		if bags.size()!=0 and (bags[0]-playernode.position).length()<=12 \
		or Global.world_data.bags.has(bag_dropping_pos):
			# We will drop the bag somewhere around the player
			bag_dropping_pos = Global.find_position_for_bag()+playernode.position
		
		var item_node = get_parent().items.inventory[get_parent().selected_slot.slot_id].node
		
		# Change the selected item's quantity
		var newQuantity = get_parent().items.inventory[get_parent().selected_slot.slot_id].quantity - quantity
		item_node.get_child(0).set_text(str(newQuantity))
		get_parent().items.inventory[get_parent().selected_slot.slot_id].quantity = newQuantity
		Global.charactersData[Global.charID].inventory[get_parent().selected_slot.slot_id].quantity = newQuantity
		
		
		# If we're viewing the bag, add the other item node to bag
		if get_parent().viewing_bag and get_parent().bag_pos == bag_dropping_pos:
			# Add the new item to bag
			var item = preload("res://scenes/inventory/Item.tscn").instance()
			# Set the item's sprite and quantity
			item.texture_normal = item_node.texture_normal
			item.get_child(0).set_text(str(quantity))
			item.connect("button_down", get_parent(), "item_pressed", ["0", true])
			item.set_name("0")
			get_node("../BagGrid/Items").add_child(item)
			item.rect_position.x = (0%get_node("../BagGrid/Slots").columns)*76 + 9
			item.rect_position.y = int(0.0/float(get_node("../BagGrid/Slots").columns))*76 + 9
		
			get_parent().items.bag["0"] = {
				"item_id" : get_parent().items.inventory[get_parent().selected_slot.slot_id].item_id,
				"quantity": quantity,
				"node" : item
			}
		
		Global.world_data.bags[bag_dropping_pos] = {
			"items" : {
				"0" : {
					"item_id" : get_parent().items.inventory[get_parent().selected_slot.slot_id].item_id,
					"quantity": quantity
				}
			}
		}
		
		# Inform the server
		Networking.dropItem(get_parent().selected_slot.slot_id, bag_dropping_pos, "0", quantity)
		
		set_buttons_state()

func pickup():
	# Get the item data, which we will add to the inventory:
	var item_data = get_parent().items.bag[get_parent().selected_slot.slot_id].duplicate(true)
	
	# Find the first free slot in the inventory
	var slotID = ""
	for slot in range(Global.charactersData[Global.charID].level+20-get_parent().special_slots_count):
		if not get_parent().items.inventory.has(str(slot+get_parent().special_slots_count)):
			slotID = str(slot+get_parent().special_slots_count)
			break
	
	# If there are no free slots, don't pick up the item, and disable the pickup button
	if slotID == "":
		get_node("Drop/Label").disabled = true
		get_node("Drop/Label").add_color_override("font_color", Color8(102,102,102))
		return
	
	get_parent().clicked = {
		"slot_id" : get_parent().selected_slot.slot_id,
		"in_bag" : true,
		"node" : get_parent().items.bag[get_parent().selected_slot.slot_id].node
	}
	get_parent().move_to(slotID, false)
	
	get_parent().unselect_slot()

func drop():
	# Get the item data, which we will add to the bag:
	var item_data = get_parent().items.inventory[get_parent().selected_slot.slot_id].duplicate(true)
	var item_node = item_data.node
	item_data.erase("node")
	
	var bags = []
	# Check if there's a bag nearby to which to drop the item to
	for bag_pos in Global.world_data.bags.keys():
		# Check if that bag is not private
		if not Global.world_data.bags[bag_pos].has("player") or ( Global.world_data.bags[bag_pos].has("player") and Global.world_data.bags[bag_pos].player==get_tree().get_network_unique_id() ):
			bags.append(bag_pos)
	# Sort the bags by distance from the player
	bags.sort_custom(self, "sort_by_distance")
	
	# Loop throught the bags to find the nearest not-full bag that is in range
	var bag = null
	for bag_pos in bags:
		if (bag_pos-playernode.position).length()<=12:
			# Good, it's in range
			if Global.world_data.bags[bag_pos].items.size() < 20:
				# Very good, it's not full
				bag = bag_pos
				break
		else:
			break
	
	# Check if we found a valid bag
	if bag != null:
		# Hurray! There's a bag close enough for us to drop the item there!
		
		# Add the item to the bag
		# Get the slot_id of the first free slot
		var slot_id
		for i in range(20):
			if not Global.world_data.bags[bag].items.has(str(i)):
				slot_id = str(i)
				break
		# Add it
		Global.world_data.bags[bag].items[slot_id] = item_data
		
		# This will be needed to remove the slot later
		var inv_slot_id = get_parent().selected_slot.slot_id
		
		# If we're viewing this bag then instead of removing the item
		# Just move it to the bag
		if get_parent().viewing_bag and get_parent().bag_pos == bag:
			get_parent().items.bag[slot_id] = item_data
			get_parent().items.bag[slot_id].node = get_parent().selected_slot.node
			# Move the item node to bag
			get_parent().clicked = {
				"slot_id" : get_parent().selected_slot.slot_id,
				"in_bag" : false,
				"node" : get_parent().items.inventory[get_parent().selected_slot.slot_id].node
			}
			get_parent().move_to(slot_id, true)
			
		else:
			# Remove the item node
			item_node.queue_free()
		
		# Remove the item from inventory
		get_parent().items.inventory.erase(inv_slot_id)
		Global.charactersData[Global.charID].inventory.erase(inv_slot_id)
		
		# Inform the server:
		Networking.dropItem(inv_slot_id, bag, slot_id)
		
		get_parent().unselect_slot()
		return
	# There's no bag close enough, we will have to add one
	
	var bag_dropping_pos = get_parent().bag_pos if get_parent().viewing_bag else playernode.position
	
	# If there's already a bag in range, but its full
	# Or if there's a private bag in the exact same position
	if bags.size()!=0 and (bags[0]-playernode.position).length()<=12 \
	or Global.world_data.bags.has(bag_dropping_pos):
		# We will drop the bag somewhere around the player
		bag_dropping_pos = Global.find_position_for_bag()+playernode.position
	
	# Inform the server:
	Networking.dropItem(get_parent().selected_slot.slot_id, bag_dropping_pos, "0")
	
	# Add the bag with item to the dictionary
	Global.world_data.bags[bag_dropping_pos] = {"items": {"0":item_data}}
	
	# Remove the item from inventory
	get_parent().items.inventory.erase(get_parent().selected_slot.slot_id)
	Global.charactersData[Global.charID].inventory.erase(get_parent().selected_slot.slot_id)
	item_node.queue_free()
	
	# Add the visual bag to the scene
	var scene_instance = preload("res://scenes/inventory/Bag.tscn").instance()
	scene_instance.position = bag_dropping_pos
	get_node("/root/"+get_tree().get_current_scene().get_name()+"/Entities/bags").add_child(scene_instance)
	get_parent().unselect_slot()