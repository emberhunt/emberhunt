extends Node2D

#const InventoryPrefab = preload("res://scenes/Inventory.tscn")
const InventorySystem = preload("res://scripts/inventory/InventorySystem.gd")

var mainInventorySystem

var _invSystem : InventorySystem = null
var openedInv

var _openChestButton

var _invName
var _inv

func _ready():
	if get_tree().get_current_scene().get_name() == "MainServer":
		return

	mainInventorySystem = "/root/" + get_tree().get_current_scene().get_name() + "/GUI/CanvasLayer/inventorySystem"
	
	for i in range(get_child_count()):
		get_child(i).connect("on_area_entered", self, "on_interaction_range_entered")
		get_child(i).connect("on_area_exited", self, "on_interaction_range_exited")

func init(path):
	if get_tree().get_current_scene().get_name() == "MainServer":
		return
		
	_invSystem = get_node(path + "inventorySystem")
	if _invSystem == null:
		DebugConsole.error("couldn't find inventory!")

	_invSystem.connect("on_item_inventory_swapped", self, "save_items")
	_openChestButton = get_node(path + "/openChest")
	_openChestButton.connect("pressed", self, "open_inventory")
	_openChestButton.get_child(0).connect("pressed", self, "open_inventory")

func on_interaction_range_entered(invName, inventory):
	_invName = invName
	_inv = inventory
	_openChestButton.show()

func on_interaction_range_exited(_invName):
	_openChestButton.hide()
	if _invSystem.visible:
		get_node("/root/" + get_tree().get_current_scene().get_name() + "/GUI")._on_toggleInventory_pressed()
	else:
		remove_inventories()

func open_inventory():
	_openChestButton.hide()
	_invSystem.open_inventory(_invName, _inv)
	DebugConsole.write_line("adding inventory: " + _invName)
	get_node("/root/"+get_tree().get_current_scene().get_name()+"/GUI")._on_toggleInventory_pressed()
	
func remove_inventories():
	if openedInv != null:
		openedInv.hide()
	else:
		openedInv = null
		
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




