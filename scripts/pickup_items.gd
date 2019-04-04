extends Node2D

const Inventory = preload("res://scripts/inventory/Inventory.gd")

var buttonPath 

var _mainInv : Inventory = null
var _addItemButton : Button

var _canPickup = false
var _child
var _itemId
var _amount


func _ready():
	if get_tree().get_current_scene().get_name() == "MainServer":
		return
	buttonPath = "/root/" + get_tree().get_current_scene().get_name() + "/GUI/CanvasLayer/addItemButton"
	
	for i in range(get_child_count()):
		get_child(i).connect("on_pickup_range_entered", self, "pickup_range_entered")
		get_child(i).connect("on_pickup_range_exited", self, "pickup_range_exited")

func init(path):
	if get_tree().get_current_scene().get_name() == "MainServer":
		return
	_mainInv = get_node(path + "inventorySystem")
	_addItemButton = get_node(buttonPath)
	
	if _mainInv == null or _addItemButton == null:
		DebugConsole.error("couldn't find inventory!")
	#_mainInv.connect("on_item_inventory_swapped", self, "save_items")
	_addItemButton.connect("pressed", self, "pickup_item")
	_addItemButton.get_child(0).connect("pressed", self, "pickup_item")

func pickup_range_exited(child, itemId, amount):
	get_node(buttonPath).set_visible(false)
	_canPickup = false

func pickup_range_entered(child, itemId, amount):
	get_node(buttonPath).set_visible(true)
	_canPickup = true
	_child = child
	_itemId = itemId
	_amount = amount

func pickup_item():
	var addedToSlot = _mainInv.get_main_inventory().add_item(Global.allItems[_itemId], _amount)
	if addedToSlot != -1:
		if Global.nickname != "Offline":
			Networking.askServerToPickUpItem(_child.name, _amount)
		else:
			_child.call_deferred("queue_free")
		DebugConsole.write_line("picked up: " + str(_amount) + " " + Global.allItems[_itemId].get_name())
	else:
		DebugConsole.write_line("Couldn't pick up item")
		