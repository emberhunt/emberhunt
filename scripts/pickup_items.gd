extends Node2D


const Inventory = preload("res://scripts/inventory/Inventory.gd")

export(NodePath) var inventory = "/root/FortressOfTheDark/GUI/CanvasLayer/inventorySystem"
var buttonPath = "/root/FortressOfTheDark/GUI/CanvasLayer/addItemButton"
	

var _mainInv : Inventory = null
var _addItemButton : Button

var _canPickup = false
var _child
var _itemId
var _amount


func _ready():
	for i in range(get_child_count()):
		get_child(i).connect("on_pickup_range_entered", self, "pickup_range_entered")
		get_child(i).connect("on_pickup_range_exited", self, "pickup_range_exited")


func init(path):
	_mainInv = get_node(path + "inventorySystem")
	_addItemButton = get_node(path + "addItemButton")
	if _mainInv == null or _addItemButton == null:
		get_node("/root/Console/console").error("couldn't find inventory!")
	_mainInv.connect("on_item_inventory_swapped", self, "save_items")
	_addItemButton.connect("pressed", self, "pickup_item")


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
	var addedToSlot = _mainInv.get_inventory().add_item(Global.allItems[_itemId], _amount)
	if addedToSlot != -1:
		Networking.pickup_item(get_tree().get_current_scene().get_name(), _itemId, _amount, addedToSlot)
		get_node("/root/Console/console").write_line("picked up: " + str(_amount) + " " + Global.allItems[_itemId].get_name())
		remove_child(_child)
		_child.queue_free()
	else:
		get_node("/root/Console/console").write_line("Couldn't pick up item")
		