extends Node2D

const Inventory = preload("res://scripts/inventory/Inventory.gd")

var _button

var _mainInv : Inventory = null
var _addItemButton : Button

var _canPickup := false

# id : [ child, itemid, amount]
var _pickupInfo := {}
var _lastPickupItemName := ""

var _showCounter = 0


func _ready():
	if get_tree().get_current_scene().get_name() == "MainServer":
		return
	
	for i in range(get_child_count()):
		get_child(i).connect("on_pickup_range_entered", self, "pickup_range_entered")
		get_child(i).connect("on_pickup_range_exited", self, "pickup_range_exited")

func init(path):
	if get_tree().get_current_scene().get_name() == "MainServer":
		return
	_mainInv = get_node(path + "inventorySystem")
	_button = "/root/" + get_tree().get_current_scene().get_name() + "/GUI/CanvasLayer/addItemButton"
	
	if _mainInv == null or get_node(_button) == null:
		DebugConsole.error("couldn't find inventory!")
	#_mainInv.connect("on_item_inventory_swapped", self, "save_items")
	get_node(_button).connect("pressed", self, "pickup_item")
	get_node(_button).get_child(0).connect("pressed", self, "pickup_item")

func pickup_range_exited(child, itemId, amount):
	_remove_close_pickup_item(child.name)
	_canPickup = false

func pickup_range_entered(child, itemId, amount):
	_canPickup = true
	DebugConsole.warn("Current pick up item: " + str(child.name))
	_add_close_pickup_item(child, itemId, amount)

func _add_close_pickup_item(pickupItem, itemId, amount):
	_update_show_counter(1)
	_pickupInfo[pickupItem.name] = [itemId, amount]
	_lastPickupItemName = pickupItem.name

func _remove_close_pickup_item(pickupName):
	_update_show_counter(-1)
	_pickupInfo.erase(pickupName)
	if not _pickupInfo.empty():
		_lastPickupItemName = _pickupInfo.keys().back()

func _update_show_counter(counter):
	_showCounter += counter
	DebugConsole.warn(_showCounter)
	if _showCounter <= 0:
		get_node(_button).hide()
	else:
		get_node(_button).show()
		

func pickup_item():
	if _pickupInfo.empty():
		return
	var _itemId = _pickupInfo[_lastPickupItemName][0]
	var _amount = _pickupInfo[_lastPickupItemName][1]

	#var addedToSlot = _mainInv.get_main_inventory().add_item(Global.allItems[_itemId], _amount)
	if _mainInv.get_main_inventory().can_add_item(Global.allItems[_itemId]):
		#Networking.rpc_id(1, "askServerToPickUpItem", get_tree().get_network_unique_id(), _child.name, _amount)
		DebugConsole.warn("Send pick up item: " + str(_lastPickupItemName))
		Networking.askServerToPickUpItem(get_tree().get_network_unique_id(), _lastPickupItemName, _itemId,  _amount)
	else:
		DebugConsole.write_line("Can't pick up item")
		