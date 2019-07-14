# Copyright 2019 Emberhunt Team
# https://github.com/emberhunt
# Licensed under the GNU General Public License v3.0 or later
# SPDX-License-Identifier: GPL-3.0-or-later

# This file describes what should happen when a certain item is "used"
# With the USE button in the inventory.
# Examples: potions - drink, equipment - equip

var uses = {}
# This is the main variable.
# The keys in this dictionary are the item types, and the values
# Are the corresponding functions references

func _init():
	# Get the `uses` dictionary ready:
	var methods = self.get_method_list()
	# Iterate through all the methods in this object and find
	# The ones that start with "_use_", and add them to the
	# Dictionary `uses`
	for method in methods:
		if method['name'].begins_with("_use_"):
			uses[method['name'].right(5)] = funcref(self, method['name'])


# This is the only function that is called from outside
# The argument is the inventory object, or in other words
# The `self` of Inventory.gd
func use(inv):
	# First, make sure a slot is selected.
	if inv.selected_slot.empty():
		# ¯\_(ツ)_/¯
		return
	
	# Okay
	# Now figure out what's the type of the item that is selected
	var item_id
	if inv.selected_slot.in_bag:
		item_id = inv.items.bag[inv.selected_slot.slot_id].item_id
	else:
		item_id = inv.items.inventory[inv.selected_slot.slot_id].item_id
	var type = Global.items[item_id].type
	
	# Nice.
	# The time to make sure there's a function for handling that type has come
	if not uses.has(type):
		# (┛◉Д◉)┛彡┻━┻
		# WHO THOUGHT IT WOULD BE A GOOD IDEA TO ADD
		# A TYPE BUT NOT A HANDLING FUNCTION!
		print("Tried to use an item of type \""+type+"\", but there's no function for that defined. See `res://scripts/inventory/Use.gd`")
		return
	
	# Great.
	# Now we can call the corresponding function
	# To handle the call further
	uses[type].call_func(inv)

# # # # # # # # # # # # # # # # #
# Usage descriptions start here #
# # # # # # # # # # # # # # # # #


func _use_sword(inv):
	# If it's not already in the sword's special slot, move it there
	if not inv.selected_slot.in_bag and inv.selected_slot.slot_id=="0":
		# It's already there.
		return
	
	# MOVE IT
	inv.clicked = {
		"slot_id" : inv.selected_slot.slot_id,
		"in_bag" : inv.selected_slot.in_bag,
		"node" : inv.items.bag[inv.selected_slot.slot_id].node if inv.selected_slot.in_bag \
			else inv.items.inventory[inv.selected_slot.slot_id].node
	}
	# Check if there's another item in that slot
	if inv.items.inventory.has("0"):
		# We will have to swap those items
		inv.swap_with("0", false)
	else:
		# Just move it
		inv.move_to("0", false)