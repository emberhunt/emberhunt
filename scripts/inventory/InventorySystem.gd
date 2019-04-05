"""
- Each player has 1 inventory system
- Each chest (and chest like behavior entities) that have an inventory, 
  DON'T have THIS inventory system,
  instead they have an accessable inventory
- Each InventorySystem must 
- Additional inventories can be added
"""
extends Control

class_name InventorySystem

signal on_item_inventory_swapped(inv1, inv2)


const InventoryPrefab = preload("res://scenes/inventory/Inventory.tscn")
const Inventory = preload("res://scripts/inventory/Inventory.gd")
const SlotRequirement = preload("res://scripts/inventory/SlotRequirement.gd")
const Item = preload("res://scripts/inventory/ItemStats.gd")

export(bool) var weightEnabled = false
export(NodePath) var inventoriesPath = ""
export(NodePath) var mainInventoryPath = ""

onready var itemDescription = $itemSlotDescription
onready var blocker = $blocker
onready var draggenItem = $draggenItem
onready var inventoryTypes = $types

# key is the player/chest id
var _inventoryTypeNames = []

var selectedInv
var lastSelectedInv

var selectedId
var lastSelectedId

var pressedId

var holding = false

func _ready():
	var addItemRef = CommandRef.new(self, "cmd_add_item", CommandRef.COMMAND_REF_TYPE.FUNC, 1)
	var addItemCommand = Command.new('addItem',  addItemRef, [], '.', ConsoleRights.CallRights.ADMIN)
	DebugConsole.add_command(addItemCommand)

	var removeItemRef = CommandRef.new(self, "cmd_remove_item", CommandRef.COMMAND_REF_TYPE.FUNC, 1)
	var removeItemCommand = Command.new('removeItem',  removeItemRef, [], '.', ConsoleRights.CallRights.ADMIN)
	DebugConsole.add_command(removeItemCommand)
	
	var showAllItemRef = CommandRef.new(self, "cmd_show_all_items", CommandRef.COMMAND_REF_TYPE.FUNC, 0)
	var showAllItemCommand = Command.new('showAllItems',  showAllItemRef, [], '.', ConsoleRights.CallRights.ADMIN)
	DebugConsole.add_command(showAllItemCommand)
	
	set_process_input(true)
#
	# This will be loaded by file later on.
	# This to test functionality
	
	var playerEquipment = $inventories/equipment
	#playerEquipment.add_item(playerEquipment.get_item_by_id(1))
	
	var inv = $inventories/inventory
	#inv.add_item(inv.get_item_by_id(3))
	
	load_save_data({ \
			"inventory" : { "slotSize" : 20, "columns" : 5, "weightEnabled" : false, \
				"slots" : { 0 : {"item_id" : 0, "amount" : 1}}}, \
			"equipment" : { "slotSize" : 12, "columns" : 4, "weightEnabled" : false, \
				"slots" : {1 : {"item_id" : 1, "amount" : 1}}}})
	
	for i in range($inventories.get_child_count()):
		$inventories.get_child(i).connect("on_slot_toggled", self, "_on_PlayerInventory_on_slot_toggled")
	
func cmd_add_item(input : Array):
	var mainInv = $inventories/equipment
	mainInv.add_item(mainInv.get_item_by_id(int(input[0])))
	
func cmd_remove_item(input : Array):
	var mainInv = $inventories/playerInventory
	mainInv.remove_item(int(input[0]), 1)

func cmd_show_all_items(_input : Array):
	var mainInv = $inventories/playerInventory
	
	for i in range(mainInv._allItems.size()):
		DebugConsole.write_line(str(mainInv._allItems[i].get_name()))

func get_save_data():
	var saveData = {}
	saveData.inventory = {}
	saveData.equipment = {}
	saveData.inventory = $inventories.get_node("inventory").get_inventory_save_data()
	saveData.equipment = $inventories.get_node("equipment").get_inventory_save_data()

func load_save_data(data):
	#slotSize, columns, weightEnabled, data
	$inventories.get_node("inventory").load_inventory_from_data(\
			data.inventory.slotSize, data.inventory.columns, data.inventory.weightEnabled, data.inventory.slots)
	$inventories.get_node("equipment").load_inventory_from_data(\
			data.equipment.slotSize, data.equipment.columns, data.equipment.weightEnabled, data.equipment.slots)

func _process(delta):
	if holding:
		draggenItem.rect_global_position = get_viewport().get_mouse_position()

func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.is_pressed():
		holding = false
		draggenItem.set_visible(false)

func get_main_inventory():
	return $inventories/inventory

func get_equipment():
	return $inventories/equipment
	
# data is structured like: slot_id = { "item_id", "amount" }
func open_inventory(type, data):
	var inv = get_inventory_by_name(type)
	inv.show()
	inv.clear()
	for i in range(data.size()):
		var value = data[data.keys()[i]]
		inv.set_item(data.keys()[i], value.item_id, value.amount)
		DebugConsole.warn("Added: "+ str(data.keys()[i]) + " -> " + str(value.item_id))
	DebugConsole.warn("Opened " + str(type))

func close_opened_inventory(type):
	for i in range($inventories.get_child_count()):
		for l in range(_inventoryTypeNames.size()):
			if $inventories.get_child(i).name == _inventoryTypeNames:
				var inv = $inventories.get_child(i)
				inv.set_visible(false)
	DebugConsole.warn("Closed: " + str(type))

func get_inventory_by_name(invName):
	for i in range($inventories.get_child_count()):
		if $inventories.get_child(i).name == invName:
			return $inventories.get_child(i)
	DebugConsole.error("Couldn't find inventory with name: " + invName)
	return null

func remove_inventory(index):
	var inv = $inventories.get_child(index)
	inv.set_visible(false)
	
func remove_inventory_by_name(invName):
	for i in range($inventories.get_child_count()):
		if invName == $inventories.get_child(i).name:
			$inventories.get_child(i).set_visible(false)

func close_all_except_main_inventory():
	for i in range($inventories.get_child_count()):
		if $inventories.get_child(i).name == "inventory" or $inventories.get_child(i).name == "equipment":
			continue
		$inventories.get_child(i).set_visible(false)

func _on_PlayerInventory_on_slot_toggled(is_pressed, id, inv):
	if Global.paused:
		return
	
	lastSelectedInv = selectedInv
	selectedInv = inv
	lastSelectedId = selectedId
	selectedId = id
	if is_pressed:
		if get_inventory_by_name(inv).get_item(id) != null : # make dragged item visible
			holding = true
			pressedId = selectedId
			draggenItem.set_visible(true)
			draggenItem.texture = get_inventory_by_name(inv).get_slot(selectedId)._slot.get_child(0).texture
						
	elif holding and not is_pressed:
		holding = false
		
		if selectedId == pressedId and lastSelectedInv == selectedInv:
			var pos = get_inventory_by_name(inv).get_slot(pressedId)._slot.rect_global_position
			var size = get_inventory_by_name(inv).get_slot(pressedId)._slot.rect_size
			itemDescription.rect_global_position = Vector2(pos.x - size.x * 1.5, pos.y - size.y * 1.2)
			 
			itemDescription.set_description(get_inventory_by_name(inv).get_slot(pressedId).get_item())
			itemDescription.set_visible(true)
		
		# swap items
		if _check_requirements_for_slot_swap( \
				get_inventory_by_name(lastSelectedInv).get_slots()[lastSelectedId], \
				get_inventory_by_name(selectedInv).get_slots()[selectedId]):
			swap_items()

func swap_items():
	var toInv = get_inventory_by_name(selectedInv)
	var fromInv = get_inventory_by_name(lastSelectedInv)
	
	var toSlot = toInv.get_slot(selectedId)
	var fromSlot = fromInv.get_slot(lastSelectedId)
	
	var toItem = toSlot.get_item()
	var fromItem = fromSlot.get_item()
	
	# nothing to swap
	if fromItem == null and toItem == null:
		return 
	
	# not the same item, full swap
	if fromItem == null or toItem == null or fromItem.get_id() != toItem.get_id():
		_full_swap(fromInv, fromSlot, toInv, toSlot)
	# same item id
	else:
		# not stackable, full swap
		if not toItem.is_stackable(): # item2 is also stackable then (same item)
			_full_swap(fromInv, fromSlot, toInv, toSlot)
		# stackable, part swap (try stack)
		else:
			_part_swap(fromInv, fromSlot, toInv, toSlot)

func _full_swap(inv1, slot1 : Inventory.Slot, inv2, slot2 : Inventory.Slot):
	var maxWeight1 = inv1.get_max_carry_weight()
	var maxWeight2 = inv2.get_max_carry_weight()
	
	var amount = slot1.get_amount()
	
	# weight without items
	if weightEnabled:
		inv1.add_weight(-slot1.get_weight())
		inv2.add_weight(-slot2.get_weight())
	
	# no swap, if weight too much
	if weightEnabled and \
			(inv1.get_carry_weight() + slot2.get_weight() > maxWeight1) or \
			(inv2.get_carry_weight() + slot1.get_weight() > maxWeight2):
		print("can't carry anymore")
		inv1.add_weight(slot1.get_weight())
		inv2.add_weight(slot2.get_weight())
		return
	
	# swap, enough weight left too carry
	else:
		var item1 = slot1.get_item()
		var amount1 = slot1.get_amount()
		slot1.set_item(slot2.get_item(), slot2.get_amount())
		slot2.set_item(item1, amount1)
		
		if weightEnabled:
			inv1.add_weight(slot1.get_weight())
			inv2.add_weight(slot2.get_weight())
		emit_signal("on_item_inventory_swapped", inv1, inv2)

func _part_swap(fromInv, fromSlot : Inventory.Slot, toInv, toSlot : Inventory.Slot):
	var maxWeight = toInv.get_max_carry_weight()
	
	var currentWeight = toInv.get_carry_weight()
	
	# weight without items
	
	var itemWeight = toSlot.get_item().get_weight()
	var addItemsAmount = _get_carryable_items_amount(toInv, fromSlot)
	
	if toSlot.get_item().get_stack_size() < toSlot.get_amount() + addItemsAmount:
		addItemsAmount = toSlot.get_item().get_stack_size() - toSlot.get_amount()
	
	
	if addItemsAmount <= 0:
		print("can't carry anymore")
		return
	
	if weightEnabled:
		fromInv.set_weight(fromInv.get_weight() - addItemsAmount * itemWeight)
		toInv.set_weight(toInv.get_weight() + addItemsAmount * itemWeight)
	
	fromSlot.set_amount(fromSlot.get_amount() - addItemsAmount)
	toSlot.set_amount(toSlot.get_amount() + addItemsAmount)
	
	if fromSlot.get_amount() == 0:
		fromSlot.remove_item()
	
	emit_signal("on_item_inventory_swapped", fromInv, toInv)
	
func _get_carryable_items_amount(inv : Inventory, slot) -> int:
	if not weightEnabled:
		return slot.get_amount()

	var remainingCarryWeight = inv.get_remainging_carry_weight()
	for i in range(slot.get_amount()):
		if (slot.get_item().get_weight() * (slot.get_amount() - i)) > remainingCarryWeight:
			continue
		else:
			return slot.get_amount() - i
	return 0

func _check_requirements_for_slot_swap(firstSlot, secondSlot) -> bool:
	if selectedId == lastSelectedId and lastSelectedInv == selectedInv:
		return false
	if not _check_requirements_type(secondSlot.get_item(), firstSlot):
		return false
	if not _check_requirements_type(firstSlot.get_item(), secondSlot):
		return false
	return true
	
func _check_requirements_type(item, slot) -> bool:
	if item == null:
		return true
	if slot.accepts_slot_type(item.get_type()):
		return true
	return false
	
func _on_descriptionField_mouse_exited():
	itemDescription.set_visible(false)


