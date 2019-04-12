extends Node2D

#const InventoryPrefab = preload("res://scenes/Inventory.tscn")
const InventorySystem = preload("res://scripts/inventory/InventorySystem.gd")

var mainInventorySystem

var _invSystem : InventorySystem = null
var openedInv

var _openChestButton

# counts how many chests/inventories are nearby that can be opened (0 = none)
var _invCounter = 0
var _invData
var _lastInv
var _invOpened = false

func _ready():
	if get_tree().get_current_scene().get_name() == "MainServer":
		return
	
	for i in range(get_child_count()):
		get_child(i).connect("on_area_entered", self, "on_interaction_range_entered")
		get_child(i).connect("on_area_exited", self, "on_interaction_range_exited")

func init(path):
	if get_tree().get_current_scene().get_name() == "MainServer":
		return
	
	mainInventorySystem = Global.guiPath + "/CanvasLayer/inventorySystem"
	
	get_node(Global.guiPath).connect("on_inventory_toggled", self, "_update_inventory_opened")
		
	_invSystem = get_node(path + "inventorySystem")
	
	if _invSystem == null:
		DebugConsole.error("couldn't find inventory!")

	_invSystem.connect("on_item_inventory_swapped", self, "save_items")
	_openChestButton = get_node(path + "/openChest")
	_openChestButton.connect("pressed", self, "open_inventory")
	_openChestButton.get_child(0).connect("pressed", self, "open_inventory")

func _get_inventory_index(invName : String) -> int:
	for i in range(_invSystem.get_child_count()):
		if _invSystem.get_child(i).name == invName:
			return i
	return -1

func on_interaction_range_entered(invName, inventory):
	_invData = inventory
	_lastInv = invName
	DebugConsole.write_line("Current inventory: " + _lastInv)
	_update_inventory_counter(1)

func on_interaction_range_exited(_invName):
	_update_inventory_counter(-1)
	
func _update_inventory_opened(open):
	_invOpened = open
	if open:
		_openChestButton.hide()
	else:
		_update_inventory_counter(0)
	
func _update_inventory_counter(count):
	_invCounter += count
	if _invCounter <= 0:
		if _invSystem.visible:
			get_node(Global.guiPath)._on_toggleInventory_pressed()
		else:
			remove_inventories()
		_openChestButton.hide()
	else:
		_openChestButton.show()

func open_inventory():
	_openChestButton.hide()
	DebugConsole.write_line("adding inventory: " + _lastInv)
	_invSystem.open_inventory(_lastInv, _invData)
	get_node(Global.guiPath)._on_toggleInventory_pressed()
	
func remove_inventories():
	_invSystem.close_all_except_main_inventory()
	DebugConsole.write_line("remove inventories")

func save_items(inv1, inv2):
	DebugConsole.write_line("saving items...")
#	if inv1.get_id() == openedInv.get_id():
#		for i in range(inv1._slots.size()):
#			openedInv._slots[i] = inv1._slots[i] 
#			if inv1._slots[i]._item != null:
#				get_node("/root/Console").write_line(inv1._slots[i]._item.get_name())
#	elif inv2.get_id() == openedInv.get_id():
#		for i in range(inv2._slots.size()):
#			openedInv._slots[i] = inv2._slots[i] 
#			if inv2._slots[i]._item != null:
#				get_node("/root/Console").write_line(inv2._slots[i]._item.get_name())

#	for i in range(openedInvs.size()):
#		if inv == openedInvs[i].get_id() or targetInv == openedInvs[i].get_id():
#			get_node(openedInvs[i].name)._slots = openedInvs[i]._slots
#			get_node("/root/Console").write_line("found and saved")
#			break




