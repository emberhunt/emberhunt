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


const Inventory = preload("res://scripts/Inventory.gd")
const SlotRequirement = preload("res://scripts/SlotRequirement.gd")

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
	set_process_input(true)
	
	var invs = get_node(inventoriesPath)
	for i in range(invs.get_child_count()):
		invs.get_child(i)._set_id(i)
		_inventories.append(invs.get_child(i))
		#_inventories[invs.get_child(i).get_id()] = invs.get_child(i)
		_inventories[invs.get_child(i).get_id()].connect("on_slot_toggled", self, "_on_PlayerInventory_on_slot_toggled")
	
	_mainInventoryId = get_node(mainInventoryPath).get_id()
	
	# This will be loaded by file later on.
	# This to test functionality
	
	var playerEquipment = $inventories/equipment
	playerEquipment.add_item(playerEquipment.get_item_by_id(0))
	playerEquipment.add_item(playerEquipment.get_item_by_id(0))
	playerEquipment.add_item(playerEquipment.get_item_by_id(1))
	playerEquipment.add_item(playerEquipment.get_item_by_id(2))
	
	
	# test items / later loaded from file
	var mainInv = $inventories/playerInventory
	mainInv.add_item(mainInv.get_item_by_id(0))
	mainInv.add_item(mainInv.get_item_by_id(1))
	mainInv.add_item(mainInv.get_item_by_id(1))
	mainInv.add_item(mainInv.get_item_by_id(1))
	mainInv.add_item(mainInv.get_item_by_id(1))
	mainInv.add_item(mainInv.get_item_by_id(1))
	mainInv.add_item(mainInv.get_item_by_id(1))
	mainInv.add_item(mainInv.get_item_by_id(1))
	mainInv.add_item(mainInv.get_item_by_id(1))
	mainInv.add_item(mainInv.get_item_by_id(1))
	mainInv.add_item(mainInv.get_item_by_id(1))
	mainInv.add_item(mainInv.get_item_by_id(1))
	mainInv.add_item(mainInv.get_item_by_id(1))
	mainInv.add_item(mainInv.get_item_by_id(1))
	mainInv.add_item(mainInv.get_item_by_id(1))
	mainInv.add_item(mainInv.get_item_by_id(1))
	mainInv.add_item(mainInv.get_item_by_id(1))
	mainInv.add_item(mainInv.get_item_by_id(3))
	mainInv.add_item(mainInv.get_item_by_id(3))
	mainInv.add_item(mainInv.get_item_by_id(3))
	mainInv.add_item(mainInv.get_item_by_id(3))
	mainInv.add_item(mainInv.get_item_by_id(3))
	
	
	var chest = $inventories/chest
	chest.add_item(chest.get_item_by_id(0))
	chest.add_item(chest.get_item_by_id(3))
	
	var chest2 = $inventories/chest2
	chest2.add_item(chest2.get_item_by_id(1))
	chest2.add_item(chest2.get_item_by_id(1))
	chest2.add_item(chest2.get_item_by_id(1))
	chest2.add_item(chest2.get_item_by_id(1))
	chest2.add_item(chest2.get_item_by_id(1))
	chest2.add_item(chest2.get_item_by_id(1))
	chest2.add_item(chest2.get_item_by_id(3))
	chest2.add_item(chest2.get_item_by_id(3))
	chest2.add_item(chest2.get_item_by_id(3))
	chest2.add_item(chest2.get_item_by_id(3))
	chest2.add_item(chest2.get_item_by_id(3))
	
	
func _process(delta):
	if holding:
		draggenItem.rect_global_position = get_viewport().get_mouse_position()


func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.is_pressed():
		holding = false
		draggenItem.set_visible(false)


func get_inventory():
	return _inventories[_mainInventoryId]
	

func add_inventory(inventory : Inventory):
	inventory._set_id(_inventories.size())
	_inventories.append(inventory)
	
	
func remove_inventory(index):
	_inventories.remove(index)
	
	
func remove_inventory_by_name(invName):
	for i in range(_inventories.size()):
		if invName != _inventories.keys()[i]:
			_inventories.remove(i)


func remove_all_except_main_inventory():
	for i in range(_inventories.size() - 1):
		_inventories.remove(1)


func _on_PlayerInventory_on_slot_toggled(is_pressed, id, inv):
	if Global.paused:
		return
		
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
	var lastSelItem = _inventories[lastSelectedInv].get_item(lastSelectedId)
	var selItem = _inventories[selectedInv].get_item(selectedId)
	
	var lastItemWeight = _inventories[lastSelectedInv].get_slot_weight(lastSelectedId)
	var selItemWeight = _inventories[selectedInv].get_slot_weight(selectedId)
	
	var lastSelItemAmount = _inventories[lastSelectedInv].get_item_amount(lastSelectedId)
	var selItemAmount = _inventories[selectedInv].get_item_amount(selectedId)
	
	#print("+ " + str(selItemAmount))
	#print("+ " + str(lastSelItemAmount))
	
	var carryAmount = _get_carryable_items_amount(_inventories[selectedInv], lastSelItem, lastSelItemAmount)
	
	var lastWeightBef = _inventories[lastSelectedInv].get_slot(lastSelectedId).get_weight()
	var weightBef = _inventories[selectedInv].get_slot(selectedId).get_weight()		
	var lastWeightAfter = 0
	var weightAfter = _inventories[selectedInv].get_slot(selectedId).get_weight()		
	
	if (lastSelItem == null and selItem != null) or \
				(lastSelItem != null and selItem == null) or \
				(lastSelItem != null and selItem != null and lastSelItem.get_id() != selItem.get_id()):
		
		var diff = lastSelItemAmount - carryAmount
		if lastSelectedInv != selectedInv:
			if diff == lastSelItemAmount:
				print("can't carry anymore")
				return
			elif diff != 0:
				selItemAmount = diff
				lastSelItemAmount = carryAmount
				_inventories[lastSelectedInv].set_item(lastSelectedId, lastSelItem, selItemAmount)
				_inventories[selectedInv].set_item(selectedId, lastSelItem, lastSelItemAmount)
			
			else:
				_inventories[lastSelectedInv].set_item(lastSelectedId, selItem, selItemAmount)
				_inventories[selectedInv].set_item(selectedId, lastSelItem, lastSelItemAmount)
		else:
			_inventories[lastSelectedInv].set_item(lastSelectedId, selItem, selItemAmount)
			_inventories[selectedInv].set_item(selectedId, lastSelItem, lastSelItemAmount)
		
		lastWeightAfter = _inventories[lastSelectedInv].get_slot(lastSelectedId).get_weight()
		weightAfter = _inventories[selectedInv].get_slot(selectedId).get_weight()	
		
	elif lastSelItem.get_id() == selItem.get_id() and \
				lastSelItem.is_stackable() and selItem.is_stackable():
		if lastSelectedInv != selectedInv:
			if carryAmount == 0:
				print("can't carry anymore")
				return
			elif carryAmount != lastSelItemAmount:
				lastSelItemAmount = carryAmount

		var diff =  selItem.get_stack_size() - (lastSelItemAmount + selItemAmount)

		if diff < 0: # diff < 0 the stack has overflow
			diff = int(abs(diff))
			_inventories[selectedInv].get_slot(selectedId).set_amount(selItem.get_stack_size())
			lastWeightAfter = _inventories[lastSelectedInv].get_slot(lastSelectedId).get_weight()
			weightAfter = _inventories[selectedInv].get_slot(selectedId).get_weight()
			_inventories[lastSelectedInv].add_weight(-abs(selItem.get_weight() * (diff - lastSelItemAmount)))
			lastSelItemAmount = diff
			
		elif diff == 0: # exact the stack size
			_inventories[selectedInv].get_slot(selectedId).set_amount(selItem.get_stack_size())
			lastWeightAfter = 0
			weightAfter = _inventories[selectedInv].get_slot(selectedId).get_weight()	
			lastSelItemAmount = 0
			
		else: # the item fits on the stack
			_inventories[selectedInv].get_slot(selectedId).set_amount(lastSelItemAmount + selItemAmount)
			lastWeightAfter = 0
			weightAfter = _inventories[selectedInv].get_slot(selectedId).get_weight()
			lastSelItemAmount = 0
		
		_inventories[lastSelectedInv].get_slot(lastSelectedId).set_amount(lastSelItemAmount)
		#print(lastSelItemAmount)
		#print(_inventories[lastSelectedInv].get_slot(lastSelectedId).get_amount())
		
		if _inventories[lastSelectedInv].get_slot(lastSelectedId).get_amount() <= 0:
			_inventories[lastSelectedInv].get_slot(lastSelectedId).remove_item()
			
		#print("weight: " + str(weightAfter - weightBef))
		#print("last weight: " + str(lastWeightAfter - lastWeightBef))
	_inventories[selectedInv].add_weight(weightAfter - weightBef)
	_inventories[lastSelectedInv].add_weight(lastWeightAfter - lastWeightBef)


	var lastSelSlot = _inventories[lastSelectedInv].get_slot(lastSelectedId)
	var selSlot = _inventories[selectedInv].get_slot(selectedId)
	
	# check if the items are the same and are stackable
		
	
func _get_carryable_items_amount(inv : Inventory, item, amount : int) -> int:
	var remainingCarryWeight = inv.get_remainging_carry_weight()
	#print("remaining: " + str(remainingCarryWeight))
	for i in range(amount):
		if (item.get_weight() * (amount - i)) > remainingCarryWeight:
			continue
		else:
			return amount - i
	
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


		