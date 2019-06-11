# Copyright 2019 Emberhunt Team
# https://github.com/emberhunt
# Licensed under the GNU General Public License v3.0 or later
# SPDX-License-Identifier: GPL-3.0-or-later

extends GridContainer

onready var stats = Global.charactersData[Global.charID]

var special_slots = 4

var bagPos

func _ready():
	# Generate columns for gridContainer
	columns = int(((get_viewport().size.x-144)/2.0-80)/66.0)
	# Check if it's the bag or the inventory
	if get_node("../..").get_name() == "BagContainer":
		# It's the bag
		# Find which bag
		var playernode = get_node("/root/"+get_tree().get_current_scene().get_name()+"/Entities/player")
		# Find out the position of the nearest bag
		var nearest_bag_pos
		for bag_pos in Global.world_data.bags.keys():
			# Set the first bag as the nearest automatically because there's nothing to compare it to yet.
			if typeof(nearest_bag_pos)==0:
				nearest_bag_pos = bag_pos
				continue
			var distance = (bag_pos-playernode.position).length()
			# If this bag is nearer than the current nearest_bag_pos
			if distance < (nearest_bag_pos-playernode.position).length():
				nearest_bag_pos = bag_pos
		var bagInfo = Global.world_data.bags[nearest_bag_pos]
		bagPos = nearest_bag_pos
		# Generate slots
		for slot in range(bagInfo.size()+1):
			var scene = preload("res://scenes/inventory/InventorySlot.tscn")
			var scene_instance = scene.instance()
			scene_instance.set_name("B"+str(slot))
			add_child(scene_instance)
		# Add items to slots
		for item in range(bagInfo.size()):
			var scene_instance = preload("res://scenes/inventory/Item.tscn").instance()
			scene_instance.rect_global_position =  \
				Vector2( (item%columns)*66 + 8, \
						 int(item/float(columns))*66 + 8 \
				)
			scene_instance.itemID = bagInfo[item]["item_id"]
			scene_instance.quantity = bagInfo[item]["quantity"]
			scene_instance.slotID = int(item)
			scene_instance.in_bag = true
			get_node("../Items").add_child(scene_instance)
	else:
		# Generate inventory slots
		for slot in range(stats.level+20-special_slots):
			var scene = preload("res://scenes/inventory/InventorySlot.tscn")
			var scene_instance = scene.instance()
			scene_instance.set_name(str(slot+special_slots))
			add_child(scene_instance)
		# Add items to slots
		var items = stats['inventory']
		for item in items.keys():
			var scene_instance = preload("res://scenes/inventory/Item.tscn").instance()
			var on_special_slot = false
			if int(item) <= 3:
				on_special_slot = true
				scene_instance.rect_global_position = get_node("../../"+item).rect_global_position+Vector2(8,8)
			else:
				scene_instance.rect_global_position = Vector2(((int(item)-special_slots)%columns)*66+8,int((int(item)-special_slots)/columns)*66+8)
			scene_instance.itemID = items[item]["item_id"]
			scene_instance.quantity = items[item]["quantity"]
			scene_instance.slotID = int(item)
			if on_special_slot:
				get_node("../../ItemsInSpecialSlots").add_child(scene_instance)
			else:
				get_node("../Items").add_child(scene_instance)