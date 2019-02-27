"""
- Each player has 1 inventory system
- Each chest (and chest like behavior entities) that have an inventory, 
  DON'T have THIS inventory system,
  instead they have an accessable inventory
- Each InventorySystem has a main inventory, which will get access to other inventories
- Additional inventories can be added to the main inventory
"""
extends Control

class_name InventorySystem



const Inventory = preload("res://scripts/Inventory.gd")
const SlotRequirement = preload("res://scripts/SlotRequirement.gd")

onready var itemDescription = $itemSlotDescription
onready var itemDescriptionField = $descriptionField
onready var blocker = $blocker
onready var draggenItem = $draggenItem


#key is the player/chest id
var _inventories = {}
var _mainInventoryId : String

var selectedInv
var lastSelectedInv

var selectedId : String
var lastSelectedId : String

var pressedId : String

var holding = false

func _ready():
	set_process_input(true)
	
	
	_mainInventoryId = "equipment"
	for i in range(get_child(0).get_child_count()):
		_inventories[get_child(0).get_child(i).name] = get_child(0).get_child(i)
		_inventories[get_child(0).get_child(i).name].connect("on_slot_toggled", self, "_on_PlayerInventory_on_slot_toggled")
	
	
	# This will be loaded by file later on.
	# This to test functionality
	
	var playerEquipment = $inventories/equipment
	playerEquipment.add_item(playerEquipment.get_item(0))
	playerEquipment.add_item(playerEquipment.get_item(0))
	playerEquipment.add_item(playerEquipment.get_item(1))
	playerEquipment.add_item(playerEquipment.get_item(2))
	
	
	# test items / later loaded from file
	var mainInv = $inventories/playerInventory
	mainInv.add_item(mainInv.get_item(0))
	mainInv.add_item(mainInv.get_item(1))
	mainInv.remove_item(0)
	
	
	var chest = $inventories/chest
	chest.add_item(chest.get_item(0))
	chest.add_item(chest.get_item(3))
	
	var chest2 = $inventories/chest2
	chest2.add_item(chest2.get_item(0))
	chest2.add_item(chest2.get_item(3))
	
	# registeres inventories
	for i in range(get_child(0).get_child_count()):
		for j in range(get_child(0).get_child_count()):
			if i != j:
				var inv = _inventories[get_child(0).get_child(i).name]
				#inv.used = true
				for s in range(inv.get_slot_size()):
					var slot = inv.get_slots()[inv.inventoryName + str(s)]
					_inventories[get_child(0).get_child(j).name].register_slot(inv.inventoryName + str(s), slot)
	
	
func _process(delta):
	if holding:
		draggenItem.rect_global_position = get_viewport().get_mouse_position()


func get_inventory():
	return _inventories[_mainInventoryId]

# TODO:
# - "register" items to main inventory
func register_inventory(inventory : Inventory):
	for i in range(get_child(0).get_child_count()):
		var inv = _inventories[get_child(0).get_child(i).name]
		#inv.used = true
		for s in range(inv.get_slot_size()):
			var slot = inv.get_slots()[inv.inventoryName + str(s)]
			
			inventory.register_slot(inv.inventoryName + str(s), slot)

	
	
func unregister_inventories():
	# ToDo: add marker if inventory should be unregistred or not
	# rather than only one main inventory
	for i in range(_inventories.size()):
		if _mainInventoryId != _inventories.keys()[i]:
			_inventories.erase(_inventories.keys()[i])


func _on_PlayerInventory_on_slot_toggled(is_pressed, id, inv):
	if Global.paused:
		return
		
	lastSelectedInv = selectedInv
	selectedInv = inv
	lastSelectedId = selectedId
	selectedId = id
	
	if is_pressed:
		if _inventories[inv].get_slots()[id]._item != null :
			holding = true
			pressedId = id
			draggenItem.set_visible(true)
			draggenItem.texture = _inventories[inv].get_slots()[id]._slot.get_child(0).texture
			
			
	elif holding and not is_pressed:
		_inventories[inv].get_slots()[lastSelectedId].set_unselected()
		_inventories[inv].get_slots()[selectedId].set_unselected()
		holding = false
		
		if selectedId == pressedId:
			var pos = _inventories[inv].get_slots()[pressedId]._slot.rect_global_position
			var size = _inventories[inv].get_slots()[pressedId]._slot.rect_size
			itemDescription.rect_global_position = Vector2(pos.x + size.x * 0.5, pos.y + size.y * 0.8)
			itemDescriptionField.rect_global_position = pos
			 
			itemDescription.set_description(_inventories[inv].get_slots()[pressedId].get_item())
			blocker.set_visible(true)
			itemDescriptionField.set_visible(true)
			itemDescription.set_visible(true)
			
		if selectedId == lastSelectedId:
			return
		
		var lastSelSlot = _inventories[lastSelectedInv].get_slots()[lastSelectedId]
		var selSlot = _inventories[selectedInv].get_slots()[selectedId]
		
		if lastSelSlot.get_item() != null and selSlot.get_item() != null: 
			# check if the items are the same and are stackable
			if lastSelSlot.get_item().get_id() == selSlot.get_item().get_id() and \
					selSlot.get_item().is_stackable() and lastSelSlot.get_item().is_stackable() and \
					selSlot.get_amount() + lastSelSlot.get_amount() < selSlot.get_item().get_stack_size():
				_inventories[selectedInv].get_slots()[selectedId].set_amount(selSlot.get_amount() + lastSelSlot.get_amount())
				_inventories[lastSelectedInv].add_weight(-_inventories[lastSelectedInv].get_slots()[lastSelectedId].get_weight())
				_inventories[selectedInv].add_weight(_inventories[lastSelectedInv].get_slots()[lastSelectedId].get_weight())
				_inventories[lastSelectedInv].get_slots()[lastSelectedId].remove_item()
				return
		
		# swap items
		if _check_requirements_for_slot_swap( \
				_inventories[lastSelectedInv].get_slots()[lastSelectedId], \
				_inventories[selectedInv].get_slots()[selectedId]):
			_inventories[selectedInv].swap_items(selectedId, lastSelectedId)  # swap items
			var lastItemWeight = \
					_inventories[lastSelectedInv].get_slots()[lastSelectedId].get_weight()
			var selItemWeight = \
					_inventories[selectedInv].get_slots()[selectedId].get_weight()
					
			_inventories[selectedInv].add_weight(-lastItemWeight)
			_inventories[lastSelectedInv].add_weight(-selItemWeight)
			_inventories[selectedInv].add_weight(selItemWeight)
			_inventories[lastSelectedInv].add_weight(lastItemWeight)
			
			
			
func _check_requirements_for_slot_swap(firstSlot, secondSlot) -> bool:
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


func _on_inventorySystem_gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.is_pressed():
		holding = false
		draggenItem.set_visible(false)
		
		