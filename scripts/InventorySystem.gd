"""
- Each player has 1 inventory system
- Each chest (and chest like behavior entities) that have an inventory, 
  DON'T have THIS inventory system,
  instead they have an accessable inventory
- Each InventorySystem has a main inventory, which will get access to other inventories
- Additional Inventories can be added to the main inventory
"""
extends Control

const Inventory = preload("res://scripts/Inventory.gd")
const SlotRequirement = preload("res://scripts/SlotRequirement.gd")

onready var itemDescription = $itemSlotDescription
onready var itemDescriptionField = $descriptionField


class_name InventorySystem

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
	#set_process_input(true)
	
	for i in range(get_child(0).get_child_count()):
		if i == 0:
			_mainInventoryId = get_child(i).name
		_inventories[get_child(0).get_child(i).name] = get_child(0).get_child(i)
		_inventories[get_child(0).get_child(i).name].connect("on_slot_toggled", self, "_on_PlayerInventory_on_slot_toggled")
	
	var mainInv = $Inventories/playerInventory
	mainInv.add_item(mainInv.get_item(0))
	mainInv.add_item(mainInv.get_item(1))
	mainInv.add_item(mainInv.get_item(2))
	mainInv.add_item(mainInv.get_item(3))
	mainInv.add_item(mainInv.get_item(3))
	mainInv.add_item(mainInv.get_item(3))
	mainInv.remove_item(3)
	
	
	var chest = $Inventories/chest
	chest.add_item(chest.get_item(0))
	chest.add_item(chest.get_item(1))
	chest.add_item(chest.get_item(2))
	chest.add_item(chest.get_item(3))
	chest.add_item(chest.get_item(3))
	chest.add_item(chest.get_item(3))
	chest.remove_item(0)
	
	var chest2 = $Inventories/chest2
	chest2.add_item(chest2.get_item(0))
	chest2.add_item(chest2.get_item(1))
	chest2.add_item(chest2.get_item(2))
	chest2.add_item(chest2.get_item(3))
	chest2.add_item(chest2.get_item(3))
	chest2.add_item(chest2.get_item(3))
	chest2.remove_item(0)
	
	
	for i in range(get_child(0).get_child_count()):
		for j in range(get_child(0).get_child_count()):
			if i != j:
				var inv = _inventories[get_child(0).get_child(i).name]
				#inv.used = true
				for s in range(inv.get_slot_size()):
					var slot = inv.get_slots()[inv.inventoryName + str(s)]
					_inventories[get_child(0).get_child(j).name].register_slot(inv.inventoryName + str(s), slot)
	
#	for i in range(get_child_count()):
#		if i == 0:
#			continue
#		var inv = _inventories[get_child(i).name]
#		inv.used = true
#		for s in range(inv.get_slots().size()):
#			var slot = inv.get_slots()[inv.inventoryName + str(i)]
#			_inventories[_mainInventoryId].register_slot(inv.inventoryName + str(s), slot)
			
		
#func _input(event):
#	if not is_visible():
#		return
#
#	if event is InputEventMouseButton:
#		if event.button_index == BUTTON_RIGHT:
#			if pressedId != "":
#				_inventories[lastSelectedInv].get_slots()[pressedId]._slot.set_description_visible(false)

#func _init(mainInventory : String):
#	_mainInventoryId = mainInventory
	
	
func get_inventory():
	return _inventories[_mainInventoryId]

# TODO:
# - "register" items to main inventory
func register_inventory(inventory : Inventory):
	inventory
	
	
func unregister_inventory(inventoryId : String):
	_inventories.erase(inventoryId)


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
			
			
	elif holding and not is_pressed:
		_inventories[inv].get_slots()[lastSelectedId].set_unselected()
		_inventories[inv].get_slots()[selectedId].set_unselected()
		holding = false
		
		if selectedId == pressedId:
			var pos = _inventories[inv].get_slots()[pressedId]._slot.rect_global_position
			var size = _inventories[inv].get_slots()[pressedId]._slot.rect_size
			itemDescription.rect_global_position = Vector2(pos.x + size.x * 0.5, pos.y + size.y * 0.8)
			itemDescriptionField.rect_global_position = pos
			 
			itemDescription.set_description(_inventories[inv].get_slots()[pressedId].get_item().get_description())
			itemDescription.set_visible(true)
			itemDescriptionField.set_visible(true)
			
		if selectedId == lastSelectedId:
			return
		
		var slotRequirements = _inventories[inv].get_slots()[selectedId].get_slot_requirements()
		var itemRequirements = _inventories[lastSelectedInv].get_slots()[lastSelectedId].get_item().get_requirements()
		
		var itemType = _inventories[lastSelectedInv].get_slots()[lastSelectedId].get_item().get_type()
		var slotTypeRequirement = _inventories[inv].get_slots()[selectedId].get_slot_types()
		
		#print(slotRequirements)
		#print(itemRequirements)
		print(itemType)
		print(_inventories[inv].get_slots()[selectedId].get_slot_types())
		
		
		if _inventories[inv].get_slots()[selectedId].has_slot_type(itemType):#SlotRequirement.meet_requirements(itemRequirements, slotRequirements) and \
			# get player stats
			#if SlotRequirement.character_meets_item_requirements(playerStats, itemRequirements):
			_inventories[selectedInv].swap_items(selectedId, lastSelectedId) 
			
			
func _on_descriptionField_mouse_exited():
	if itemDescription.is_visible():
		itemDescription.set_visible(false)
		itemDescriptionField.set_visible(false)
