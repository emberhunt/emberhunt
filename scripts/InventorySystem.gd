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


class_name InventorySystem

#key is the player/chest id
var _inventories = {}
var _mainInventoryId : String

var selectedInv
var lastSelectedInv

var selectedId : String
var lastSelectedId : String

var holding = false

func _ready():
	for i in range(get_child_count()):
		if i == 0:
			_mainInventoryId = get_child(i).name
		_inventories[get_child(i).name] = get_child(i)
		_inventories[get_child(i).name].connect("on_slot_toggled", self, "_on_PlayerInventory_on_slot_toggled")
	
	var mainInv = $PlayerInventory
	mainInv.add_item(mainInv.get_item(0))
	mainInv.add_item(mainInv.get_item(1))
	mainInv.add_item(mainInv.get_item(2))
	mainInv.add_item(mainInv.get_item(3))
	mainInv.add_item(mainInv.get_item(3))
	mainInv.add_item(mainInv.get_item(3))
	mainInv.remove_item(0)
	
	
	var chest = $Chest
	chest.add_item(chest.get_item(0))
	chest.add_item(chest.get_item(1))
	chest.add_item(chest.get_item(2))
	chest.add_item(chest.get_item(3))
	chest.add_item(chest.get_item(3))
	chest.add_item(chest.get_item(3))
	chest.remove_item(0)
	
	var chest2 = $Chest2
	chest2.add_item(chest2.get_item(0))
	chest2.add_item(chest2.get_item(1))
	chest2.add_item(chest2.get_item(2))
	chest2.add_item(chest2.get_item(3))
	chest2.add_item(chest2.get_item(3))
	chest2.add_item(chest2.get_item(3))
	chest2.remove_item(0)
	
	
	for i in range(get_child_count()):
		for j in range(get_child_count()):
			if i != j:
				var inv = _inventories[get_child(i).name]
				#inv.used = true
				for s in range(inv.get_slot_size()):
					var slot = inv.get_slots()[inv.inventoryName + str(s)]
					_inventories[get_child(j).name].register_slot(inv.inventoryName + str(s), slot)
	
#	for i in range(get_child_count()):
#		if i == 0:
#			continue
#		var inv = _inventories[get_child(i).name]
#		inv.used = true
#		for s in range(inv.get_slots().size()):
#			var slot = inv.get_slots()[inv.inventoryName + str(i)]
#			_inventories[_mainInventoryId].register_slot(inv.inventoryName + str(s), slot)
			
		
	pass

func init(mainInventory : String):
	_mainInventoryId = mainInventory
	
	
func get_inventory():
	return _inventories[_mainInventoryId]

# TODO:
# - "register" items to main inventory
func register_inventory(inventory : Inventory):
	inventory
	
	
func unregister_inventory(inventoryId : String):
	_inventories.erase(inventoryId)


func _on_PlayerInventory_on_slot_toggled(is_released, id, inv):
	lastSelectedInv = selectedInv
	selectedInv = inv
	lastSelectedId = selectedId
	selectedId = id
	
	if is_released and _inventories[inv].get_slots()[id]._item != null :
		holding = true
		#print("pressed")
	elif holding and not is_released:
		#print("released")
		_inventories[inv].get_slots()[lastSelectedId].set_unselected()
		_inventories[inv].get_slots()[selectedId].set_unselected()
		if selectedId == lastSelectedId:
			return
		_inventories[selectedInv].swap_items(selectedId, lastSelectedId) 
		holding = false
			
			