# Copyright 2019 Emberhunt Team
# https://github.com/emberhunt
# Licensed under the GNU General Public License v3.0 or later
# SPDX-License-Identifier: GPL-3.0-or-later

extends TextureButton

var itemID = "woodsword"
var quantity = 0
var slotID = -1
var in_bag = false

var dragging = false
var clicked = false


var itemData = {}

onready var origin = rect_global_position
var mouse_origin = Vector2()

onready var special_slots = [
	get_node("/root/"+get_tree().get_current_scene().get_name()+"/GUI/CanvasLayer/Inventory/Container/0")
	]

var drop_item_slot

var viewing_bag

func _ready():
	viewing_bag = get_node("/root/"+get_tree().get_current_scene().get_name()+"/GUI/CanvasLayer/Inventory").has_node("BagContainer")
	if not viewing_bag:
		drop_item_slot = get_node("/root/"+get_tree().get_current_scene().get_name()+"/GUI/CanvasLayer/Inventory/Container/DropItem")
	# Read the item data
	itemData = Global.items[itemID]
	
	# Set the texture
	if itemID != "":
		texture_normal = Global.loaded_item_sprites[itemID]
	else:
		texture_normal = null
	$Quantity.set_text(str(quantity))

func _on_Item_button_down():
	origin = rect_global_position
	clicked = true
	mouse_origin = get_global_mouse_position()

# we would use button_up signal, but apparently it doesn't work after reparenting the node
func _input(event):
	if event is InputEventMouseButton:
		if clicked and not event.pressed:
			clicked = false
			if dragging:
				dragging = false
				# Iterate through all slots to see if the mouse is on any of them
				for slot in special_slots + \
				get_node("/root/"+get_tree().get_current_scene().get_name()+"/GUI/CanvasLayer/Inventory/Container/ScrollContainer/GridContainer").get_children():
					# Check x and y coordinates
					var mousepos = slot.get_local_mouse_position()
					if mousepos.x <= 64 and mousepos.x >= 0 and mousepos.y <= 64 and mousepos.y >= 0:
						# Found the slot
						# Check if it's free
						var free = true
						var other_item
						for item in get_node("/root/"+get_tree().get_current_scene().get_name()+"/GUI/CanvasLayer/Inventory/Container/ScrollContainer/Items").get_children() \
							+get_node("/root/"+get_tree().get_current_scene().get_name()+"/GUI/CanvasLayer/Inventory/Container/ItemsInSpecialSlots").get_children():
							if item.slotID == int(slot.get_name()) and not item.in_bag:
								free = false
								other_item = item
								break
						# If the item previously was in a bag, and now is dragged to inventory
						if in_bag:
							# Drop the other item to the bag
							if not free:
								Networking.dropItem(str(int(slot.get_name())))
								# This str(int( thing might look dumb, but it's not. Don't remove it.
							var bag_pos = get_node("/root/"+get_tree().get_current_scene().get_name()+"/GUI/CanvasLayer/Inventory/Container/ScrollContainer/GridContainer").bagPos
							Networking.pickupItem(bag_pos, itemID, int(slot.get_name()))
						if not free:
							# Now just move the other item to the original item's position
							other_item.rect_global_position = origin
							other_item.slotID = slotID
						slotID = int(slot.get_name())
						in_bag = false
						if slotID > 3:
							# Move self-item back to the scrollcontainer
							var scrollcontainer = get_node("/root/"+get_tree().get_current_scene().get_name()+"/GUI/CanvasLayer/Inventory/Container/ScrollContainer/Items")
							get_parent().remove_child(self)
							scrollcontainer.add_child(self)
						else:
							var itemsinspecialslots = get_node("/root/"+get_tree().get_current_scene().get_name()+"/GUI/CanvasLayer/Inventory/Container/ItemsInSpecialSlots")
							get_parent().remove_child(self)
							itemsinspecialslots.add_child(self)
						rect_global_position = slot.rect_global_position+Vector2(8,8)
						
						
						# Inform the server about the changes
						# Generate an appropriate dict
						var newInv = {}
						for item in get_node("/root/"+get_tree().get_current_scene().get_name()+"/GUI/CanvasLayer/Inventory/Container/ScrollContainer/Items").get_children() \
							+get_node("/root/"+get_tree().get_current_scene().get_name()+"/GUI/CanvasLayer/Inventory/Container/ItemsInSpecialSlots").get_children():
							if not item.in_bag:
								newInv[str(item.slotID)] = {"item_id" : item.itemID, "quantity" : item.quantity}
						# Maybe weapon changed, so re-set stats
						Global.charactersData[Global.charID].inventory = newInv
						get_node("/root/"+get_tree().get_current_scene().get_name()+"/Entities/player/weapon").set_stats()
						Networking.sendInventory(newInv)
						return
				######HERE
				# It might also be on bag slots, if we're viewing a bag
				if viewing_bag:
					# Iterate through bag slots
					for slot in get_node("../../BagContainer/ScrollContainer/GridContainer").get_children():
						# Check x and y coordinates
						var mousepos = slot.get_local_mouse_position()
						if mousepos.x <= 64 and mousepos.x >= 0 and mousepos.y <= 64 and mousepos.y >= 0:
							# Found the slot
							# Check if it's free
							var free = true
							var other_item
							var items_in_bag = 0
							for item in get_node("..").get_children():
								if item.in_bag:
									items_in_bag += 1
									if item.slotID == int(slot.get_name()):
										free = false
										other_item = item
										break
							# If the item was originally in the inventory and now is dragged to a bag
							if not in_bag:
								# Drop the item
								Networking.dropItem(str(slotID))
								# If the player is switching item with a bag
								if not free:
									# Now just move the bag item to inventory
									other_item.rect_global_position = origin
									var bag_pos = get_node("../../BagContainer/ScrollContainer/GridContainer").bagPos
									Networking.pickupItem(bag_pos, other_item.itemID, slotID)
									other_item.slotID = slotID
									other_item.in_bag = in_bag
							rect_global_position = slot.rect_global_position+Vector2(8,8)
							
							# If the slot was free, and the item was moved from inventory, we need
							# to add 1 more slot, because player might want to drop another item
							if free and not in_bag \
								and get_node("../../BagContainer/ScrollContainer/GridContainer").get_child_count() == items_in_bag+1:
								var scene = preload("res://scenes/inventory/InventorySlot.tscn")
								var scene_instance = scene.instance()
								scene_instance.set_name("B"+str(slot))
								get_node("../../BagContainer/ScrollContainer/GridContainer").add_child(scene_instance)
							
							in_bag = true
							slotID = int(slot.get_name())
							# Inform the server about the changes
							# Generate the new inventory dict
							var newInv = {}
							for item in get_node("..").get_children():
								if not item.in_bag:
									newInv[str(item.slotID)] = {"item_id" : item.itemID, "quantity" : item.quantity}
							# Maybe weapon changed, so re-set stats
							Global.charactersData[Global.charID].inventory = newInv
							get_node("/root/"+get_tree().get_current_scene().get_name()+"/Entities/player/weapon").set_stats()
							return
				
				# If it's not on any of the slots, then maybe it's on the DROP-ITEM plate
				if not viewing_bag: # there's no DROP-ITEM slot when viewing a bag
					var rel_mouse_pos = drop_item_slot.get_local_mouse_position()
					if rel_mouse_pos.x <= 300 and rel_mouse_pos.x >= 0 and rel_mouse_pos.y <= 120 and rel_mouse_pos.y >= 0:
						# Drop the item on ground:
						#   remove it from inventory
						Global.charactersData[Global.charID].inventory.erase(str(slotID))
						# It might have been the equipped weapon, so re-set weapon stats
						get_node("/root/"+get_tree().get_current_scene().get_name()+"/Entities/player/weapon").set_stats()
						# Add a bag on the ground
						# Maybe there's already a bag, so iterate through all bags to check
						var playernode = get_node("/root/"+get_tree().get_current_scene().get_name()+"/Entities/player")
						var bag_exists = false
						for bag_pos in Global.world_data.bags.keys():
							if (bag_pos-playernode.position).length() <= 16:
								bag_exists = true
								break
						# If bag exists, we don't have to do anything - the server will take care of it
						# However if it doesn't exist, we will have to add one.
						if not bag_exists:
							var scene_instance = preload("res://scenes/inventory/ItemBag.tscn").instance()
							scene_instance.position = playernode.position
							get_node("/root/"+get_tree().get_current_scene().get_name()+"/Entities/bags").add_child(scene_instance)
						# Inform the server
						Networking.dropItem(str(slotID))
						queue_free()
						return
				# If the item was dropped not on a slot
				
				if slotID > 3:
					# Move self-item back to the scrollcontainer
					var scrollcontainer = get_node("/root/"+get_tree().get_current_scene().get_name()+"/GUI/CanvasLayer/Inventory/Container/ScrollContainer/Items")
					get_parent().remove_child(self)
					scrollcontainer.add_child(self)
				rect_global_position = origin
			else:
				# Show info about item
				var info_window = preload("res://scenes/inventory/ItemInfo.tscn").instance()
				info_window.set_name("ItemInfo")
				info_window.positionWindowOnScreen(rect_global_position, get_viewport().size)
				info_window.rect_global_position = Vector2(0,0)
				# Each item type has different item infos
				var infoFormatter = {
					"drops_from" : PoolStringArray(itemData["drops_from"]).join(", "),
					"stat_restrictions" : dict_to_string(itemData['stat_restrictions']),
					"stat_effects" : dict_to_string(itemData['stat_effects']),
					"damage" : str(itemData['min_damage']) if itemData['min_damage']==itemData['max_damage'] else str(itemData['min_damage'])+"-"+str(itemData['max_damage']),
					"fire_rate" : str(itemData['min_fire_rate']) if itemData['min_fire_rate']==itemData['max_fire_rate'] else str(itemData['min_fire_rate'])+"-"+str(itemData['max_fire_rate']),
					"bullets" : str(itemData['min_bullets']) if itemData['min_bullets']==itemData['max_bullets'] else str(itemData['min_bullets'])+"-"+str(itemData['max_bullets']),
					"bullet_speed" : str(itemData['min_speed']) if itemData['min_speed']==itemData['max_speed'] else str(itemData['min_speed'])+"-"+str(itemData['max_speed']),
					"bullet_range" : str(itemData['min_range']) if itemData['min_range']==itemData['max_range'] else str(itemData['min_range'])+"-"+str(itemData['max_range']),
					"bullet_spread" : str(itemData['bullet_spread']) if itemData['bullet_spread_random']==0 else str(itemData['bullet_spread']*(1-itemData['bullet_spread_random']))+"-"+str(itemData['bullet_spread']*(1+itemData['bullet_spread_random'])),
					"bullet_scale" : str(itemData['min_scale']) if itemData['min_scale']==itemData['max_scale'] else str(itemData['min_scale'])+"-"+str(itemData['max_scale']),
					"bullet_knockback" : str(itemData['min_knockback']) if itemData['min_knockback']==itemData['max_knockback'] else str(itemData['min_knockback'])+"-"+str(itemData['max_knockback']),
					"bullet_pierces" : "No" if itemData['max_pierces'] <= 0 else "Yes, "+str(itemData['min_pierces']) if itemData['min_pierces']==itemData['max_pierces'] else "Yes, "+str(itemData['min_pierces'])+"-"+str(itemData['max_pierces']),
					"heavy_attack" : "Yes" if itemData['heavy_attack'] else "No"
				}
				var infoLeft = Global.item_types[itemData.type].infoLeft.format(infoFormatter)
				var infoRight = Global.item_types[itemData.type].infoRight.format(infoFormatter)
				
				info_window.get_node("Background/Control/ItemTitle").set_text(itemData.title)
				info_window.get_node("Background/Control/ItemDescription").set_text(itemData.description)
				info_window.get_node("Background/Control/ItemType").set_text(itemData.type)
				info_window.get_node("Background/Control/ItemInfoLeft").set_text(infoLeft)
				info_window.get_node("Background/Control/ItemInfoRight").set_text(infoRight)
				info_window.get_node("Background/Control/ItemRarity").set_text("Rarity: "+str(itemData.rarity))
				get_node("../../..").add_child(info_window)

func dict_to_string(dict):
	if dict.size() == 0:
		return "None"
	var string = ""
	for key in dict.keys():
		string += "+"+str(dict[key])+" "+str(key)+", " if dict[key] > 0 else str(dict[key])+" "+str(key)+", "
	
	return string.rstrip(", ")

func _process(delta):
	if clicked and not dragging:
		# Check if we need to start dragging
		if (mouse_origin-get_global_mouse_position()).length() > 20:
			dragging = true
			rect_global_position = get_global_mouse_position()-Vector2(24,24)
			# Move the item out of scroll container, to make it appear above all items
			# (doesn't apply to items in special slots)
			if slotID > 3:
				var outside = get_node("../../../..")
				get_parent().remove_child(self)
				outside.add_child(self)
				get_parent().move_child(self,get_parent().get_child_count())
	if dragging:
		rect_global_position = get_global_mouse_position()-Vector2(24,24)

