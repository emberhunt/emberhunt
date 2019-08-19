# Copyright 2019 Emberhunt Team
# https://github.com/emberhunt
# Licensed under the GNU General Public License v3.0 or later
# SPDX-License-Identifier: GPL-3.0-or-later

extends Control


onready var stats = Global.charactersData[Global.charID]

var item_types_allowed_in_special_slots = {}
#								Example: { "0" : ["sword", "staff"] }

var selected_slot : Dictionary = {}

var clicked : Dictionary = {}
var dragging : bool = false
var dragged_item_origin : Vector2
var mouse_origin : Vector2

onready var inventory_scroll_items = get_node("InventoryGrid/Items")
onready var non_scroll_items = get_node("ItemsNotInScroll")
onready var bag_scroll_items

onready var special_slots_count = get_node("SpecialSlots").get_child_count()

var items = {
	inventory={},
	bag={}
}
var slots = {
	inventory={},
	bag={}
}

var viewing_bag = false
var bag_pos

onready var playernode = get_node("/root/"+get_tree().get_current_scene().get_name()+"/Entities/player")

func sort_by_distance(a, b):
	return (a-playernode.position).length() < (b-playernode.position).length()

func _ready():
	# Get the item_types_allowed_in_special_slots ready
	for item_type in Global.item_types.keys():
		if Global.item_types[item_type].has("special_slots"):
			for special_slot in Global.item_types[item_type].special_slots.keys():
				if stats["class"] in Global.item_types[item_type].special_slots[special_slot]:
					# Okay, we know that this item type is allowed in that special slot
					# Now add it
					if item_types_allowed_in_special_slots.has(special_slot):
						item_types_allowed_in_special_slots[special_slot].append(item_type)
					else:
						item_types_allowed_in_special_slots[special_slot] = [item_type]
	
	viewing_bag = has_node("BagGrid")
	if viewing_bag:
		bag_scroll_items = get_node("BagGrid/Items")
		# Iterate through all known bags to find the nearest one
		var bags = []
		for bag_pos in Global.world_data.bags.keys():
			# Make sure its not a private bag
			if not Global.world_data.bags[bag_pos].has("player") or ( Global.world_data.bags[bag_pos].has("player") and Global.world_data.bags[bag_pos].player==get_tree().get_network_unique_id() ):
				bags.append(bag_pos)
		# Sort the bags by distance from the player
		bags.sort_custom(self, "sort_by_distance")
		# The nearest bag is the bag we are looking at
		bag_pos = bags[0]
	# Calculate the maximum amount of slots in one line for the grids
	# If we're viewing a bag, both grids will be smaller
	if viewing_bag:
		get_node("InventoryGrid/Slots").columns = int((get_node("InventoryGrid").rect_size.x)/76.0)
		get_node("BagGrid/Slots").columns = int((get_node("BagGrid").rect_size.x)/76.0)
	else:
		# If it's normal inventory
		get_node("InventoryGrid/Slots").columns = int((get_node("InventoryGrid").rect_size.x)/76.0)
	
	
	# Generate the inventory slots
	var scene = preload("res://scenes/inventory/Slot.tscn")
	for slot in range(stats.level+20 - special_slots_count ):
		var scene_instance = scene.instance()
		scene_instance.set_name(str(slot+special_slots_count))
		get_node("InventoryGrid/Slots").add_child(scene_instance)
		
		slots.inventory[str(slot+special_slots_count)] = scene_instance
	
	# Generate the bag slots (if we're viewing a bag)
	if viewing_bag:
		for slot in range(20):
			var scene_instance = scene.instance()
			scene_instance.set_name(str(slot))
			get_node("BagGrid/Slots").add_child(scene_instance)
			
			slots.bag[str(slot)] = scene_instance
	
	# Add special slots to slot_nodes
	for special_slot in get_node("SpecialSlots").get_children():
		slots.inventory[str(special_slot.get_name())] = special_slot
	
	
	# Generate items
	scene = preload("res://scenes/inventory/Item.tscn")
	
	# First: inventory items
	var inventory = stats.inventory
	for item in inventory.keys():
		var scene_instance = scene.instance()
		
		# If the item is meant to be in a special slot, but is not allowed there on this character
		# Highlight it a bit with the red-ish shader
		if Global.item_types[ Global.items[ inventory[item].item_id ].type ].has("special_slots"):
			for special_slot in Global.item_types[ Global.items[ inventory[item].item_id ].type ].special_slots.keys():
				if not allowed_in_slot(inventory[item].item_id, special_slot):
					scene_instance.set_material(preload("res://shaders/red-ish.tres"))
				else:
					break
		
		# Set the item's sprite and quantity
		scene_instance.texture_normal = Global.get_item_sprite(inventory[item].item_id)
		scene_instance.get_child(0).set_text(str(inventory[item].quantity))
		
		items.inventory[item] = {
			item_id=inventory[item].item_id,
			quantity=inventory[item].quantity,
			node=scene_instance
			}
		scene_instance.connect("button_down", self, "item_pressed", [item, false])
		# If the item is in a special slot
		if int(item) < special_slots_count:
			# Position the item on the slot
			scene_instance.rect_global_position = get_node("SpecialSlots/"+item).rect_global_position + Vector2(9,9)
			scene_instance.set_name(item)
			get_node("ItemsNotInScroll").add_child(scene_instance)
		else:
			# Position the item on the slot
			scene_instance.rect_position.x = ((int(item)-special_slots_count)%get_node("InventoryGrid/Slots").columns)*76 + 9
			scene_instance.rect_position.y = int((float(item)-special_slots_count)/float(get_node("InventoryGrid/Slots").columns))*76 + 9
			scene_instance.set_name(item)
			get_node("InventoryGrid/Items").add_child(scene_instance)
	
	# Then items in bag
	if viewing_bag:
		var bag_items = Global.world_data.bags[bag_pos].items
		for item in bag_items.keys():
			var scene_instance = scene.instance()
			
			# If the item is meant to be in a special slot, but is not allowed there on this character
			# Highlight it a bit with the red-ish shader
			if Global.item_types[ Global.items[ bag_items[item].item_id ].type ].has("special_slots"):
				for special_slot in Global.item_types[ Global.items[ bag_items[item].item_id ].type ].special_slots.keys():
					if not allowed_in_slot(bag_items[item].item_id, special_slot):
						scene_instance.set_material(preload("res://shaders/red-ish.tres"))
					else:
						break
			
			# Set the item's sprite and quantity
			scene_instance.texture_normal = Global.get_item_sprite(bag_items[item].item_id)
			scene_instance.get_child(0).set_text(str(bag_items[item].quantity))
			
			items.bag[item] = {
				item_id=bag_items[item].item_id,
				quantity=bag_items[item].quantity,
				node=scene_instance
				}
			scene_instance.connect("button_down", self, "item_pressed", [item, true])
			
			# Position the item on the slot
			scene_instance.rect_position.x = ((int(item))%get_node("BagGrid/Slots").columns)*76 + 9
			scene_instance.rect_position.y = int((float(item))/float(get_node("BagGrid/Slots").columns))*76 + 9
			scene_instance.set_name(item)
			get_node("BagGrid/Items").add_child(scene_instance)

func select_slot(slot):
	# If the same slot is selected twice in a row, then its unselected
	if not selected_slot.empty():
		selected_slot.node.get_node("Slot/Select").set_visible(false)
		if selected_slot.node == slot:
			selected_slot = {}
			get_node("Buttons").set_buttons_state()
			return
	# Set the selection animation visible
	slot.get_node("Slot/Select").set_visible(true)
	selected_slot = {"slot_id":slot.get_name(), "in_bag": slot.get_parent().get_parent().get_name()=="BagGrid", "node": slot}
	get_node("Buttons").set_buttons_state()

func unselect_slot():
	if not selected_slot.empty():
		selected_slot.node.get_node("Slot/Select").set_visible(false)
		selected_slot = {}
		get_node("Buttons").set_buttons_state()

func item_pressed(slot_id : String, in_bag: bool):
	# Gets called whenever any item is pressed
	clicked = {"slot_id":slot_id, "in_bag":in_bag}
	if in_bag:
		clicked['node'] = items.bag[slot_id].node
	else:
		clicked['node'] = items.inventory[slot_id].node
	mouse_origin = get_global_mouse_position()
	dragged_item_origin = clicked['node'].rect_global_position

func _process(delta):
	if not clicked.empty() and not dragging:
		# Check if we need to start dragging
		if (mouse_origin-get_global_mouse_position()).length() > 20:
			dragging = true
			# Rename it, D stands for Dragged
			clicked.node.set_name(clicked.node.get_name()+"D")
			# If the item is in scroll container, move it out, for visual reasons
			if clicked.in_bag:
				bag_scroll_items.remove_child(clicked.node)
			else:
				if int(clicked.slot_id) >= special_slots_count:
					inventory_scroll_items.remove_child(clicked.node)
				else:
					return
			non_scroll_items.add_child(clicked.node)
	if dragging:
		clicked.node.rect_global_position = get_global_mouse_position()-Vector2(24,24)

func _input(event):
	if event is InputEventMouseButton and not event.pressed and not clicked.empty():
		# If dragging wasnt started then select that slot
		if not dragging:
			if clicked.in_bag:
				select_slot(slots.bag[clicked.slot_id])
			else:
				select_slot(slots.inventory[clicked.slot_id])
		else:
			# An item was released somewhere
			
			# As the items are automatically synced with the server, it's possible that by the time
			# An item is released somewhere, the player is not posssessing it anymore
			# So we need to just ignore the release
			if clicked.in_bag:
				if not items.bag.has(clicked.slot_id):
					# Remove the node
					clicked.node.queue_free()
					return
			else:
				if not items.inventory.has(clicked.slot_id):
					# Remove the node
					clicked.node.queue_free()
					return
			
			# Check if it's on any slots
			
			var slot_id = ""
			var slot_in_bag = false
			# First check inventory slots
			for id in slots.inventory.keys():
				var slot = slots.inventory[id]
				if 	clicked.node.rect_global_position.x+24 >= slot.rect_global_position.x and \
					clicked.node.rect_global_position.x+24 <= slot.rect_global_position.x+slot.rect_size.x and \
					clicked.node.rect_global_position.y+24 >= slot.rect_global_position.y and \
					clicked.node.rect_global_position.y+24 <= slot.rect_global_position.y+slot.rect_size.y:
					
					# Found a slot on which the item was dropped
					slot_id = id
					slot_in_bag = false
					break
			# If the slot wasn't found, continue to search in bag slots
			if slot_id=="":
				for id in slots.bag.keys():
					var slot = slots.bag[id]
					if 	clicked.node.rect_global_position.x+24 >= slot.rect_global_position.x and \
						clicked.node.rect_global_position.x+24 <= slot.rect_global_position.x+slot.rect_size.x and \
						clicked.node.rect_global_position.y+24 >= slot.rect_global_position.y and \
						clicked.node.rect_global_position.y+24 <= slot.rect_global_position.y+slot.rect_size.y:
						
						# Found the slot on which the item was dropped

						slot_id = id
						slot_in_bag = true
						break
			# If no slot was found, return the item to it's origin
			if slot_id=="":
				move_item_back()
			else:
				
				var item_id
				if clicked.in_bag:
					item_id = items.bag[clicked.slot_id].item_id
				else:
					item_id = items.inventory[clicked.slot_id].item_id
				
				if not slot_in_bag and not allowed_in_slot(item_id, slot_id):
					# Its not allowed. Move the Item back to its original position
					move_item_back()
					clicked = {}
					dragging = false
					return
			
				var target_slot
				if slot_in_bag:
					target_slot = slots.bag[slot_id]
				else: 
					target_slot = slots.inventory[slot_id]
				 
				# Now check if there's another item in that slot
				if (slot_in_bag and items.bag.has(slot_id)) \
				or (not slot_in_bag and items.inventory.has(slot_id)):
					# It's possible the both items are actually the same item,
					# in that case just move the item back and do nothing
					# 
					# This happens when the user starts dragging an item
					# And then drops it in the same position
					# (maybe picked up wrong item?)
					if clicked.in_bag == slot_in_bag and slot_id == clicked.slot_id:
						move_item_back()
						clicked = {}
						dragging = false
						return
					
					var target_item
					if slot_in_bag:
						target_item = items.bag[slot_id]
					else: 
						target_item = items.inventory[slot_id]
					
					
					var dragged_item
					if clicked.in_bag:
						dragged_item = items.bag[clicked.slot_id]
					else:
						dragged_item = items.inventory[clicked.slot_id]
					
					# If both items are the same, and neither of them is full, we can merge them
					if dragged_item.item_id == target_item.item_id:
						# Also the item's type must have a stack_size bigger than 1
						if Global.item_types[ Global.items[ dragged_item.item_id ].type ].has("stack_size") \
						and Global.item_types[ Global.items[ dragged_item.item_id ].type ].stack_size > 1:
							# Also neither of the items should be full
							if dragged_item.quantity < Global.item_types[ Global.items[ dragged_item.item_id ].type ].stack_size \
							and target_item.quantity < Global.item_types[ Global.items[ dragged_item.item_id ].type ].stack_size:
								
								merge_with(slot_id, slot_in_bag, dragged_item, target_item)
								return
					
					# Otherwise, swap their positions.
					swap_with(slot_id, slot_in_bag)
					return
				
				# No other item, so just move
				move_to(slot_id, slot_in_bag)
			
		clicked = {}
		dragging = false

func move_to(target_item_slot_id : String, in_bag : bool):
	# If the dragged item was selected, unselect
	if not selected_slot.empty():
		if (clicked.slot_id==selected_slot.slot_id and clicked.in_bag == selected_slot.in_bag):
			unselect_slot()
	
	# Reparent:
	var newParent
	var target_slot
	if in_bag:
		newParent = bag_scroll_items
		target_slot = slots.bag[target_item_slot_id]
	else:
		target_slot = slots.inventory[target_item_slot_id]
		if int(target_item_slot_id) < special_slots_count:
			newParent = non_scroll_items
		else:
			newParent = inventory_scroll_items
	clicked.node.get_parent().remove_child(clicked.node)
	newParent.add_child(clicked.node)
	clicked.node.rect_global_position = target_slot.rect_global_position+Vector2(9,9)
	
	# Rename the node
	clicked.node.set_name(target_item_slot_id)
	# Reconnect signals
	clicked.node.disconnect("button_down", self, "item_pressed")
	clicked.node.connect("button_down", self, "item_pressed", [target_item_slot_id, in_bag])
	# There are 4 possible moves:
	match [clicked.in_bag, in_bag]:
		[false,false]:
			# Inventory -> inventory
			items.inventory[target_item_slot_id] = items.inventory[clicked.slot_id].duplicate(true)
			items.inventory.erase(clicked.slot_id)
			stats.inventory[target_item_slot_id] = \
				stats.inventory[clicked.slot_id]
			stats.inventory.erase(clicked.slot_id)
			# Inform the server
			Networking.changeInventoryLayout(stats.inventory)
		[false,true]:
			# Inventory -> bag
			items.bag[target_item_slot_id] = items.inventory[clicked.slot_id].duplicate(true)
			items.inventory.erase(clicked.slot_id)
			# Its possible that the bag is not there anymore because its empty,
			# In that case, add it yet again
			if not Global.world_data.bags.has(bag_pos):
				Global.world_data.bags[bag_pos] = {"items": {}}
			else:
				# Make sure it's not a private bag
				if Global.world_data.bags[bag_pos].has("player") and not Global.world_data.bags[bag_pos].player != get_tree().get_network_unique_id():
					# Ohh boy, it is.
					# We will need to add another bag nearly and drop the item to it
					bag_pos = Global.find_position_for_bag()
			Global.world_data.bags[bag_pos].items[target_item_slot_id] = \
				stats.inventory[clicked.slot_id]
			stats.inventory.erase(clicked.slot_id)
			# Inform the server
			Networking.dropItem(clicked.slot_id, bag_pos, target_item_slot_id)
		[true,false]:
			# Bag -> inventory
			items.inventory[target_item_slot_id] = items.bag[clicked.slot_id].duplicate(true)
			items.bag.erase(clicked.slot_id)
			stats.inventory[target_item_slot_id] = \
				Global.world_data.bags[bag_pos].items[clicked.slot_id]
			Global.world_data.bags[bag_pos].items.erase(clicked.slot_id)
			# Inform the server
			Networking.pickupItem(bag_pos, clicked.slot_id, target_item_slot_id)
		[true,true]:
			# Bag -> bag
			items.bag[target_item_slot_id] = items.bag[clicked.slot_id].duplicate(true)
			items.bag.erase(clicked.slot_id)
			Global.world_data.bags[bag_pos].items[target_item_slot_id] = \
				Global.world_data.bags[bag_pos].items[clicked.slot_id]
			Global.world_data.bags[bag_pos].items.erase(clicked.slot_id)
			# Inform the server
			Networking.changeBagLayout(bag_pos, Global.world_data.bags[bag_pos].items)
	clicked = {}
	dragging = false
	get_node("Buttons").set_buttons_state()


func move_item_back():
	var newParent
	if clicked.in_bag:
		newParent = bag_scroll_items
	else:
		if int(clicked.slot_id) < special_slots_count:
			newParent = non_scroll_items
		else:
			newParent = inventory_scroll_items
	clicked.node.get_parent().remove_child(clicked.node)
	newParent.add_child(clicked.node)
	clicked.node.set_name(clicked.node.get_name().rstrip("D"))
	clicked.node.rect_global_position = dragged_item_origin
	get_node("Buttons").set_buttons_state()

func swap_with(target_item_slot_id : String, in_bag : bool):
	# Check if the target item is allowed in the dragged item's slot
	# (We already checked if the dragged item is allowed in the target slot)
	var item_id
	if in_bag:
		item_id = items.bag[target_item_slot_id].item_id
	else:
		item_id = items.inventory[target_item_slot_id].item_id
	if not clicked.in_bag and not allowed_in_slot(item_id, clicked.slot_id):
		move_item_back()
		clicked = {}
		dragging = false
		return
	
	# If any of the 2 items is selected, unselect it
	if not selected_slot.empty():
		if (clicked.slot_id==selected_slot.slot_id and clicked.in_bag == selected_slot.in_bag) \
		or (target_item_slot_id==selected_slot.slot_id and in_bag == selected_slot.in_bag):
			unselect_slot()
	
	var target_item_container
	if clicked.in_bag:
		target_item_container = bag_scroll_items
	else:
		if int(clicked.slot_id) < special_slots_count:
			target_item_container = non_scroll_items
		else:
			target_item_container = inventory_scroll_items
	
	var dragged_item_container
	var target_item_node
	if in_bag:
		dragged_item_container = bag_scroll_items
		target_item_node = items.bag[target_item_slot_id]
	else:
		if int(target_item_slot_id) < special_slots_count:
			dragged_item_container = non_scroll_items
		else:
			dragged_item_container = inventory_scroll_items
		target_item_node = items.inventory[target_item_slot_id]
	
	# Save target item's position, because it might change after reparenting
	var old_target_item_pos = target_item_node.node.rect_global_position
	
	# Move the items to their containers
	clicked.node.get_parent().remove_child(clicked.node)
	dragged_item_container.add_child(clicked.node)
	
	target_item_node.node.get_parent().remove_child(target_item_node.node)
	target_item_container.add_child(target_item_node.node)
	
	# move both items to new positions
	target_item_node.node.rect_global_position = dragged_item_origin
	clicked.node.rect_global_position = old_target_item_pos
	
	# The visual stuff is done
	# Now rename the item nodes
	
	target_item_node.node.set_name("TEMP")
	clicked.node.set_name(target_item_slot_id)
	target_item_node.node.set_name(clicked.slot_id)
	
	# Reconnect signals with new slot_id
	target_item_node.node.disconnect("button_down", self, "item_pressed")
	clicked.node.disconnect("button_down", self, "item_pressed")
	target_item_node.node.connect("button_down", self, "item_pressed", [clicked.slot_id, clicked.in_bag])
	clicked.node.connect("button_down", self, "item_pressed", [target_item_slot_id, in_bag])
	
	# Lets update the inventory (+bag) dictionaries
	var newInventory = {}
	var newItemsInventory = {}
	for item in inventory_scroll_items.get_children() \
		+non_scroll_items.get_children(): # <- items in special slots
		
		# Remember we renamed the swapped nodes, so we need to read their data from different entries
		if item.get_name() == target_item_slot_id and not in_bag:
			if clicked.in_bag:
				newInventory[item.get_name()] = {"item_id" : items.bag[clicked.slot_id].item_id, "quantity" : items.bag[clicked.slot_id].quantity}
			else:
				newInventory[item.get_name()] = {"item_id" : items.inventory[clicked.slot_id].item_id, "quantity" : items.inventory[clicked.slot_id].quantity}
		elif item.get_name() == clicked.slot_id and not clicked.in_bag:
			if in_bag:
				newInventory[item.get_name()] = {"item_id" : items.bag[target_item_slot_id].item_id, "quantity" : items.bag[target_item_slot_id].quantity}
			else:
				newInventory[item.get_name()] = {"item_id" : items.inventory[target_item_slot_id].item_id, "quantity" : items.inventory[target_item_slot_id].quantity}
		else:
			newInventory[item.get_name()] = {"item_id" : items.inventory[item.get_name()].item_id, "quantity" : items.inventory[item.get_name()].quantity}
		
		newItemsInventory[item.get_name()] = {
			item_id=newInventory[item.get_name()].item_id,
			quantity=newInventory[item.get_name()].quantity,
			node=item
			}
	
	
	# Now bag:
	var newBagLayout = {}
	var newBagLayoutWithNodes = {}
	# If neither of the swapped items was in a bag, then nothing in the bag could have changed
	if in_bag or clicked.in_bag:
		for item in bag_scroll_items.get_children():
			# Remember we renamed the swapped nodes, so we need to read their data from different entries
			if item.get_name() == target_item_slot_id and in_bag:
				if clicked.in_bag:
					newBagLayout[item.get_name()] = {"item_id" : items.bag[clicked.slot_id].item_id, "quantity" : items.bag[clicked.slot_id].quantity}
					newBagLayoutWithNodes[item.get_name()] = {"item_id" : items.bag[clicked.slot_id].item_id, "quantity" : items.bag[clicked.slot_id].quantity, "node" : clicked.node}
				else:
					newBagLayout[item.get_name()] = {"item_id" : items.inventory[clicked.slot_id].item_id, "quantity" : items.inventory[clicked.slot_id].quantity}
					newBagLayoutWithNodes[item.get_name()] = {"item_id" : items.inventory[clicked.slot_id].item_id, "quantity" : items.inventory[clicked.slot_id].quantity, "node" : clicked.node}
			elif item.get_name() == clicked.slot_id and clicked.in_bag:
				if in_bag:
					newBagLayout[item.get_name()] = {"item_id" : items.bag[target_item_slot_id].item_id, "quantity" : items.bag[target_item_slot_id].quantity}
					newBagLayoutWithNodes[item.get_name()] = {"item_id" : items.bag[target_item_slot_id].item_id, "quantity" : items.bag[target_item_slot_id].quantity, "node" : target_item_node.node}
				else:
					newBagLayout[item.get_name()] = {"item_id" : items.inventory[target_item_slot_id].item_id, "quantity" : items.inventory[target_item_slot_id].quantity}
					newBagLayoutWithNodes[item.get_name()] = {"item_id" : items.inventory[target_item_slot_id].item_id, "quantity" : items.inventory[target_item_slot_id].quantity, "node" : target_item_node.node}
			else:
				newBagLayout[item.get_name()] = {"item_id" : items.bag[item.get_name()].item_id, "quantity" : items.bag[item.get_name()].quantity}
				newBagLayoutWithNodes[item.get_name()] = {"item_id" : items.bag[item.get_name()].item_id, "quantity" : items.bag[item.get_name()].quantity, "node" : item}
		items.bag = newBagLayoutWithNodes
		Global.world_data.bags[bag_pos].items = newBagLayout
	
	items.inventory = newItemsInventory
	# Maybe weapon changed, so re-set stats
	stats.inventory = newInventory
	get_node("/root/"+get_tree().get_current_scene().get_name()+"/Entities/player/weapon").set_stats()
	
	
	# Inform the server about what happened
	# There are 4 possible swaps:
	match [clicked.in_bag, in_bag]:
		# 1. inventory <-> inventory
		[false, false]:
			Networking.changeInventoryLayout(stats.inventory)
		# 2. inventory <-> bag
		[false, true]:
			Networking.swapItem(clicked.slot_id, target_item_slot_id, bag_pos)
		# 3. bag <-> inventory
		[true, false]:
			Networking.swapItem(target_item_slot_id, clicked.slot_id, bag_pos)
		# 4. bag <-> bag
		[true, true]:
			Networking.changeBagLayout(bag_pos, Global.world_data.bags[bag_pos].items)
	
	clicked = {}
	dragging = false
	get_node("Buttons").set_buttons_state()

func merge_with(target_item_slot_id : String, in_bag : bool, dragged_item, target_item):
	# If the sum of their quantities is more than the stack_size
	# That means we will take some quantity from the clicked item
	# And add it to the target item to make it full
	if (dragged_item.quantity+target_item.quantity) > \
		Global.item_types[ Global.items[ dragged_item.item_id ].type ].stack_size:
		# Partial merge

		# The target item must now become full
		# And the dragged item's new quantity should decrease 
		var target_new_quantity = Global.item_types[ Global.items[ dragged_item.item_id ].type ].stack_size
		var dragged_new_quantity = dragged_item.quantity - (target_new_quantity - target_item.quantity)
		
		# First of all move the dragged item back
		move_item_back()
		
		# Change dragged item's quantity
		dragged_item.node.get_child(0).set_text(str(dragged_new_quantity))
		if clicked.in_bag:
			items.bag[clicked.slot_id].quantity = dragged_new_quantity
			Global.world_data.bags[bag_pos].items[clicked.slot_id].quantity = dragged_new_quantity
		else:
			items.inventory[clicked.slot_id].quantity = dragged_new_quantity
			stats.inventory[clicked.slot_id].quantity = dragged_new_quantity
		
		# Change target item's quantity
		target_item.node.get_child(0).set_text(str(target_new_quantity))
		if in_bag:
			items.bag[target_item_slot_id].quantity = target_new_quantity
			Global.world_data.bags[bag_pos].items[target_item_slot_id].quantity = target_new_quantity
		else:
			items.inventory[target_item_slot_id].quantity = target_new_quantity
			stats.inventory[target_item_slot_id].quantity = target_new_quantity
		
	else:
		# Full merge
		
		# If the dragged item is selected, unselect it
		if not selected_slot.empty():
			if (clicked.slot_id==selected_slot.slot_id and clicked.in_bag == selected_slot.in_bag):
				unselect_slot()
		var newQuantity = dragged_item.quantity+target_item.quantity
		
		# Remove dragged item
		clicked.node.queue_free()
		# Change inventory/bag dictionaries
		if clicked.in_bag:
			items.bag.erase(clicked.slot_id)
			Global.world_data.bags[bag_pos].items.erase(clicked.slot_id)
		else:
			items.inventory.erase(clicked.slot_id)
			stats.inventory.erase(clicked.slot_id)
		
		# Change target item's quantity
		target_item.node.get_child(0).set_text(str(newQuantity))
		if in_bag:
			items.bag[target_item_slot_id].quantity = newQuantity
			Global.world_data.bags[bag_pos].items[target_item_slot_id].quantity = newQuantity
		else:
			items.inventory[target_item_slot_id].quantity = newQuantity
			stats.inventory[target_item_slot_id].quantity = newQuantity
	
	# Inform the server about what happened
	# There are 4 possible merges:
	match [clicked.in_bag, in_bag]:
		# 1. inventory <-> inventory
		[false, false]:
			Networking.changeInventoryLayout(stats.inventory)
		# 2. inventory <-> bag
		[false, true]:
			Networking.mergeItem(clicked.slot_id, target_item_slot_id, bag_pos, true)
		# 3. bag <-> inventory
		[true, false]:
			Networking.mergeItem(target_item_slot_id, clicked.slot_id, bag_pos, false)
		# 4. bag <-> bag
		[true, true]:
			Networking.changeBagLayout(bag_pos, Global.world_data.bags[bag_pos].items)
	
	clicked = {}
	dragging = false
	get_node("Buttons").set_buttons_state()

func allowed_in_slot(item_id, special_slot_id):
	# If it's a special slot, check if the item is allowed to be in that slot
	if int(special_slot_id) < special_slots_count:
		var item_type = Global.items[ item_id ].type
		
		# Now there are 2 things to check: if the item type is allowed in that special slot
		# And if the item's individual stat requirements are met
		if item_types_allowed_in_special_slots.has(special_slot_id):
			if not item_types_allowed_in_special_slots[special_slot_id].has(item_type):
				return false
		else:
			return false
		
		# Check individual stat requirements
		if Global.items[item_id].has("stat_restrictions"):
			for restriction in Global.items[item_id].stat_restrictions.keys():
				if Global.items[item_id].stat_restrictions[restriction] > stats[restriction]:
					return false
	return true

func update_gui():
	# Update stats
	stats = Global.charactersData[Global.charID]
	
	# Do not update gui when an item is being dragged
	if dragging:
		return
	# To compare the old inventory (and maybe bag) with the new one,
	# We will need to make a dictionary without nodes
	var old_inv = {}
	for slot_id in items.inventory.keys():
		old_inv[slot_id] = items.inventory[slot_id].duplicate(true)
	var scene = preload("res://scenes/inventory/Item.tscn")
	# Compare the inventories
	for slot in range(Global.charactersData[Global.charID].level+20):
		match [old_inv.has(str(slot)), Global.charactersData[Global.charID].inventory.has(str(slot))]:
			[true, true]:
				# Both inventories have something in that slot
				var node = old_inv[str(slot)].node
				# Check if the items have the same item_id
				if old_inv[str(slot)].item_id != Global.charactersData[Global.charID].inventory[str(slot)].item_id:
					# update
					items.inventory[str(slot)].item_id = Global.charactersData[Global.charID].inventory[str(slot)].item_id
					
					# If the item is meant to be in a special slot, but is not allowed there on this character
					# Highlight it a bit with the red-ish shader
					if Global.item_types[ Global.items[ items.inventory[str(slot)].item_id ].type ].has("special_slots"):
						for special_slot in Global.item_types[ Global.items[ items.inventory[str(slot)].item_id ].type ].special_slots.keys():
							if not allowed_in_slot(items.inventory[str(slot)].item_id, special_slot):
								node.set_material(preload("res://shaders/red-ish.tres"))
							else:
								node.set_material(null)
								break
					
					# Change the texture
					node.texture_normal = Global.get_item_sprite(Global.charactersData[Global.charID].inventory[str(slot)].item_id)
				# Check if the items have the same quantity
				if str(old_inv[str(slot)].quantity) != str(Global.charactersData[Global.charID].inventory[str(slot)].quantity):
					# Change the quantity
					items.inventory[str(slot)].quantity = Global.charactersData[Global.charID].inventory[str(slot)].quantity
					node.get_child(0).set_text(str(Global.charactersData[Global.charID].inventory[str(slot)].quantity))
				# In case weapon changed, reset stats
				get_node("/root/"+get_tree().get_current_scene().get_name()+"/Entities/player/weapon").set_stats()
			[false, true]:
				# Old inventory doesnt have anything in that slot, but the new has
				# Add it
				var item = scene.instance()
				
				# If the item is meant to be in a special slot, but is not allowed there on this character
				# Highlight it a bit with the red-ish shader
				if Global.item_types[ Global.items[ Global.charactersData[Global.charID].inventory[str(slot)].item_id ].type ].has("special_slots"):
					for special_slot in Global.item_types[ Global.items[ Global.charactersData[Global.charID].inventory[str(slot)].item_id ].type ].special_slots.keys():
						if not allowed_in_slot(Global.charactersData[Global.charID].inventory[str(slot)].item_id, special_slot):
							item.set_material(preload("res://shaders/red-ish.tres"))
						else:
							item.set_material(null)
							break
				
				# Set the item's sprite and quantity
				item.texture_normal = Global.get_item_sprite(Global.charactersData[Global.charID].inventory[str(slot)].item_id)
				item.get_child(0).set_text(str(Global.charactersData[Global.charID].inventory[str(slot)].quantity))
				item.connect("button_down", self, "item_pressed", [str(slot), false])
				
				# If the item is in a special slot
				if slot < special_slots_count:
					# Position the item on the slot
					item.rect_global_position = get_node("SpecialSlots/"+str(slot)).rect_global_position + Vector2(9,9)
					item.set_name(str(slot))
					get_node("ItemsNotInScroll").add_child(item)
				else:
					# Position the item on the slot
					item.rect_position.x = ((slot-special_slots_count)%get_node("InventoryGrid/Slots").columns)*76 + 9
					item.rect_position.y = int(float(slot-special_slots_count)/float(get_node("InventoryGrid/Slots").columns))*76 + 9
					item.set_name(str(slot))
					get_node("InventoryGrid/Items").add_child(item)
				items.inventory[str(slot)] = {
					"item_id" : Global.charactersData[Global.charID].inventory[str(slot)].item_id,
					"quantity": Global.charactersData[Global.charID].inventory[str(slot)].quantity,
					"node" : item
				}
				# In case weapon changed, reset stats
				get_node("/root/"+get_tree().get_current_scene().get_name()+"/Entities/player/weapon").set_stats()
			[true, false]:
				# There was something in that slot, but now isnt
				# Remove it
				# If it's being dragged right now, don't remove it, it will be removed when it's dropped
				if clicked.empty() or (not clicked.empty() and (clicked.in_bag == true or clicked.slot_id != str(slot))):
					old_inv[str(slot)].node.queue_free()
				items.inventory.erase(str(slot))
				# In case weapon changed, reset stats
				get_node("/root/"+get_tree().get_current_scene().get_name()+"/Entities/player/weapon").set_stats()
	
	# Compare the bag contents, (if we're viewing one)
	if viewing_bag:
		var old_bag = {}
		for slot_id in items.bag.keys():
			old_bag[slot_id] = items.bag[slot_id].duplicate(true)
		# Compare the bags
		for slot in range(20):
			match [old_bag.has(str(slot)), false if not Global.world_data.bags.has(bag_pos) else Global.world_data.bags[bag_pos].items.has(str(slot))]:
				[true, true]:
					var node = old_bag[str(slot)].node
					# Both bag have something in that slot
					# Check if the items have the same item_id
					if old_bag[str(slot)].item_id != Global.world_data.bags[bag_pos].items[str(slot)].item_id:
						# update
						items.bag[str(slot)].item_id = Global.world_data.bags[bag_pos].items[str(slot)].item_id
						
						# If the item is meant to be in a special slot, but is not allowed there on this character
						# Highlight it a bit with the red-ish shader
						if Global.item_types[ Global.items[ items.bag[str(slot)].item_id ].type ].has("special_slots"):
							for special_slot in Global.item_types[ Global.items[ items.bag[str(slot)].item_id ].type ].special_slots.keys():
								if not allowed_in_slot(items.bag[str(slot)].item_id, special_slot):
									node.set_material(preload("res://shaders/red-ish.tres"))
								else:
									node.set_material(null)
									break
						
						# Change the texture
						node.texture_normal = Global.get_item_sprite(Global.world_data.bags[bag_pos].items[str(slot)].item_id)
					# Check if the items have the same quantity
					if str(old_bag[str(slot)].quantity) != str(Global.world_data.bags[bag_pos].items[str(slot)].quantity):
						# Change the quantity
						items.bag[str(slot)].quantity = Global.world_data.bags[bag_pos].items[str(slot)].quantity
						node.get_child(0).set_text(str(Global.world_data.bags[bag_pos].items[str(slot)].quantity))
				[false, true]:
					# Old bag doesnt have anything in that slot, but the new has
					# Add it
					var item = scene.instance()
					
					# If the item is meant to be in a special slot, but is not allowed there on this character
					# Highlight it a bit with the red-ish shader
					if Global.item_types[ Global.items[ Global.world_data.bags[bag_pos].items[str(slot)].item_id ].type ].has("special_slots"):
						for special_slot in Global.item_types[ Global.items[ Global.world_data.bags[bag_pos].items[str(slot)].item_id ].type ].special_slots.keys():
							if not allowed_in_slot(Global.world_data.bags[bag_pos].items[str(slot)].item_id, special_slot):
								item.set_material(preload("res://shaders/red-ish.tres"))
							else:
								item.set_material(null)
								break
					
					# Set the item's sprite and quantity
					item.texture_normal = Global.get_item_sprite(Global.world_data.bags[bag_pos].items[str(slot)].item_id)
					item.get_child(0).set_text(str(Global.world_data.bags[bag_pos].items[str(slot)].quantity))
					item.connect("button_down", self, "item_pressed", [str(slot), true])
					
					# Position the item on the slot
					item.rect_position.x = (slot%get_node("BagGrid/Slots").columns)*76 + 9
					item.rect_position.y = int((float(slot))/float(get_node("BagGrid/Slots").columns))*76 + 9
					item.set_name(str(slot))
					get_node("BagGrid/Items").add_child(item)
					items.bag[str(slot)] = {
						"item_id" : Global.world_data.bags[bag_pos].items[str(slot)].item_id,
						"quantity": Global.world_data.bags[bag_pos].items[str(slot)].quantity,
						"node" : item
					}
				[true, false]:
					# There was something in that slot, but now isnt
					# Remove it
					items.bag.erase(str(slot))
					old_bag[str(slot)].node.queue_free()
	
	get_node("Buttons").set_buttons_state()