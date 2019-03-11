extends Node2D

#const InventoryPrefab = preload("res://scenes/Inventory.tscn")
const InventorySystem = preload("res://scripts/inventory/InventorySystem.gd")

export(NodePath) var mainInventorySystem = null

var _mainInv : InventorySystem = null
var openedInv

func _ready():
	if mainInventorySystem == null:
		printerr("no inventory selected!")

	for i in range(get_child_count()):
		get_child(i).connect("on_area_entered", self, "add_to_main_inventory")
		get_child(i).connect("on_area_exited", self, "remove_inventories")


func save_items(inv1, inv2):
	get_node("/root/Console").write_line("saving items...")
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

func add_to_main_inventory(invName, inventory):
	openedInv = inventory
	openedInv.show()
	get_node("/root/Console").write_line("test adding inventory")
	#openedInv = InventoryPrefab.instance()
	#openedInv.update_inventory_size(12)
	#var inv = _mainInv.create_inventory(invName, slots)
	
	if _mainInv == null:
		_mainInv = get_node("/root/"+get_tree().get_current_scene().get_name()+"/GUI/CanvasLayer/inventorySystem")
		if _mainInv != null:
			_mainInv.connect("on_item_inventory_swapped", self, "save_items")
	if _mainInv != null:
		inventory._set_id(_mainInv.add_inventory(inventory))
	#get_node("/root/Console").write_line("id: " + str(openedInv.get_id()))
	
	#inv.update_inventory_size(slots.size())
	#inv._slots = slots
	#openedInv = inv
	#openedInvs.append(inv)

func remove_inventories(invName):
	openedInv.hide()
	
	if _mainInv == null:
		_mainInv = get_node("/root/"+get_tree().get_current_scene().get_name()+"/GUI/CanvasLayer/inventorySystem")
		if _mainInv != null:
			_mainInv.connect("on_item_inventory_swapped", self, "save_items")
	
	_mainInv.remove_all_except_main_inventory()
	get_node("/root/Console").write_line("remove inventories")









