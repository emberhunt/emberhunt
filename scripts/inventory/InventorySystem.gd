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


const InventoryPrefab = preload("res://scenes/Inventory.tscn")
const Inventory = preload("res://scripts/inventory/Inventory.gd")
const SlotRequirement = preload("res://scripts/inventory/SlotRequirement.gd")
const Item = preload("res://scripts/inventory/ItemStats.gd")

export(NodePath) var inventoriesPath = ""
export(NodePath) var mainInventoryPath = ""

onready var itemDescription = $itemSlotDescription
onready var itemDescriptionField = $descriptionField
onready var blocker = $blocker
onready var draggenItem = $draggenItem


# key is the player/chest id
var _inventories = []
var _mainInventoryId : int

var selectedInv
var lastSelectedInv

var selectedId : int
var lastSelectedId : int

var pressedId : int

var holding = false

func _ready():
	var addItemRef = CommandRef.new(self, "cmd_add_item", CommandRef.COMMAND_REF_TYPE.FUNC, 1)
	var addItemCommand = Command.new('addItem',  addItemRef, [], '.', ConsoleRights.CallRights.ADMIN)
	get_node("/root/Console/console").add_command(addItemCommand)

	var removeItemRef = CommandRef.new(self, "cmd_remove_item", CommandRef.COMMAND_REF_TYPE.FUNC, 1)
	var removeItemCommand = Command.new('removeItem',  removeItemRef, [], '.', ConsoleRights.CallRights.ADMIN)
	get_node("/root/Console/console").add_command(removeItemCommand)
	
	var showAllItemRef = CommandRef.new(self, "cmd_show_all_items", CommandRef.COMMAND_REF_TYPE.FUNC, 0)
	var showAllItemCommand = Command.new('showAllItems',  showAllItemRef, [], '.', ConsoleRights.CallRights.ADMIN)
	get_node("/root/Console/console").add_command(showAllItemCommand)
	
	set_process_input(true)
#
	_mainInventoryId = 0#get_node(mainInventoryPath).get_id()
	
	# This will be loaded by file later on.
	# This to test functionality
	
	var playerEquipment = $inventories/equipment
	playerEquipment.add_item(playerEquipment.get_item_by_id(1))
	
	var chest = $inventories/chest
	chest.add_item(chest.get_item_by_id(3))
	
	add_inventory(chest)
	add_inventory(playerEquipment)
	
	
func cmd_add_item(input : Array):
	var mainInv = $inventories/equipment
	get_node("/root/Console/console").new_line()
	get_node("/root/Console/console").append_message_without_history(str(mainInv.get_carry_weight()))
	mainInv.add_item(mainInv.get_item_by_id(int(input[0])))
	get_node("/root/Console/console").new_line()
	get_node("/root/Console/console").append_message_without_history(str(mainInv.get_carry_weight()))
	
	
func cmd_remove_item(input : Array):
	var mainInv = $inventories/playerInventory
	get_node("/root/Console/console").new_line()
	get_node("/root/Console/console").append_message_without_history(str(mainInv.get_carry_weight()))
	mainInv.remove_item(int(input[0]), 1)
	get_node("/root/Console/console").new_line()
	get_node("/root/Console/console").append_message_without_history(str(mainInv.get_carry_weight()))


func cmd_show_all_items(_input : Array):
	var mainInv = $inventories/playerInventory
	
	for i in range(mainInv._allItems.size()):
		get_node("/root/Console/console").new_line()
		get_node("/root/Console/console").append_message_without_history(str(mainInv._allItems[i].get_name()))
	#mainInv.remove_item(int(input[0]), 1)
	#get_node("/root/Console/console").new_line()
	#get_node("/root/Console/console").append_message_without_history(str(mainInv.get_carry_weight()))

	
func _process(delta):
	if holding:
		draggenItem.rect_global_position = get_viewport().get_mouse_position()


func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.is_pressed():
		holding = false
		draggenItem.set_visible(false)


func get_inventory():
	return _inventories[_mainInventoryId]
	
	
# return the id of the created inventory
func create_inventory(invName, itemList):
	var inventory : Inventory = InventoryPrefab.instance()
	inventory.update_inventory_size(12)
	
	get_child(0).add_child(inventory)
	inventory._set_id(_inventories.size())
	inventory.name = invName
	
	for item in itemList:
		inventory.add_item(item._item)
	
	_inventories.append(inventory)
	_inventories[_inventories.size() - 1].connect("on_slot_toggled", self, "_on_PlayerInventory_on_slot_toggled")
	get_node("/root/Console").write_line("added i: " + inventory.name)
	
	return _inventories[_inventories.size() - 1]

func add_inventory(inventory):
	#var inventory = Inventory.new()
	inventory._set_id(_inventories.size())
	_inventories.append(inventory)
#	for i in range(inventory._slots.size()):
#		if inventory._slots[i]._item != null:
#			_inventories[_inventories.size() - 1].add_item(inventory._slots[i]._item)
#			get_node("/root/Console").write_line("added item: " + inventory._slots[i]._item.get_name())
	_inventories[_inventories.size() - 1].connect("on_slot_toggled", self, "_on_PlayerInventory_on_slot_toggled")
	get_child(0).add_child(inventory)
	#inventory.name = invName
	get_node("/root/Console").write_line("added i: " + inventory.name)
	
	return _inventories.size() - 1
	#for item in itemList:
	#	inventory.add_item(item)
	
	
	#get_child(0).add_child(inventory)
	#_inventories[_inventories.size() - 1].set_visible(true)
	#_inventories[_inventories.size() - 1].rect_global_position = rect_global_position
	

func remove_inventory(index):
	#_inventories[_inventories.size() - 1].set_visible(false)
	#_inventories[index].set_visible(false)
	_inventories.remove(index)
	
	get_child(0).remove_child(get_child(index))

	
func remove_inventory_by_name(invName):
	for i in range(_inventories.size()):
		if invName != _inventories.keys()[i]:
			_inventories.remove(i)


func remove_all_except_main_inventory():
	for i in range(_inventories.size() - 2):
		_inventories.remove(2)
		#get_child(0).get_child(i+2).free()
		get_child(0).remove_child(get_child(i+2))


func _on_PlayerInventory_on_slot_toggled(is_pressed, id, inv):
	if Global.paused:
		return
	
	get_node("/root/Console").write_line(id)
	
	lastSelectedInv = selectedInv
	selectedInv = inv
	lastSelectedId = selectedId
	selectedId = id
		
	#print(selectedId)
	#print(selectedInv)
	
	if is_pressed: 
		if _inventories[inv].get_item(id) != null : # make dragged item visible
			holding = true
			pressedId = selectedId
			draggenItem.set_visible(true)
			draggenItem.texture = _inventories[inv].get_slot(selectedId)._slot.get_child(0).texture
			#print("pressed: " + str(pressedId))
			
	elif holding and not is_pressed:
		#_inventories[inv].get_slots()[lastSelectedId].set_unselected()
		#_inventories[inv].get_slots()[selectedId].set_unselected()
		holding = false
		
		if selectedId == pressedId and lastSelectedInv == selectedInv:
			var pos = _inventories[inv].get_slot(pressedId)._slot.rect_global_position
			var size = _inventories[inv].get_slot(pressedId)._slot.rect_size
			itemDescription.rect_global_position = Vector2(pos.x + size.x * 0.5, pos.y + size.y * 0.8)
			itemDescriptionField.rect_global_position = pos
			 
			itemDescription.set_description(_inventories[inv].get_slot(pressedId).get_item())
			blocker.set_visible(true)
			itemDescriptionField.set_visible(true)
			itemDescription.set_visible(true)
		
		# swap items
		if _check_requirements_for_slot_swap( \
				_inventories[lastSelectedInv].get_slots()[lastSelectedId], \
				_inventories[selectedInv].get_slots()[selectedId]):
			swap_items()
			#_inventories[selectedInv].swap_items(selectedId, lastSelectedId)  # swap items


func swap_items():
	var toInv = _inventories[selectedInv]
	var fromInv = _inventories[lastSelectedInv]
	
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
	inv1.add_weight(-slot1.get_weight())
	inv2.add_weight(-slot2.get_weight())
	
	# no swap, if weight too much
	if (inv1.get_carry_weight() + slot2.get_weight() > maxWeight1) or \
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
	
	fromInv.set_weight(fromInv.get_weight() - addItemsAmount * itemWeight)
	toInv.set_weight(toInv.get_weight() + addItemsAmount * itemWeight)
	
	fromSlot.set_amount(fromSlot.get_amount() - addItemsAmount)
	toSlot.set_amount(toSlot.get_amount() + addItemsAmount)
	
	if fromSlot.get_amount() == 0:
		fromSlot.remove_item()
	
	emit_signal("on_item_inventory_swapped", fromInv, toInv)
	
	# check if enough stacksize available
	



func _get_carryable_items_amount(inv : Inventory, slot) -> int:
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
	if itemDescription.is_visible():
		itemDescription.set_visible(false)
		itemDescriptionField.set_visible(false)
		blocker.set_visible(false)


		