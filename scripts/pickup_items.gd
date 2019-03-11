extends Node2D


const Inventory = preload("res://scripts/inventory/Inventory.gd")

export(NodePath) var inventory = null

var _mainInv : Inventory = null


func _ready():
	if inventory == null:
		printerr("no inventory selected!")
		return
	
	_mainInv = get_node(inventory).get_inventory()
	for i in range(get_child_count()):
		get_child(i).connect("on_pickup_range_entered", self, "add_to_inventory")


func add_to_inventory(child, itemId, amount):
	if _mainInv.add_item(Global.allItems[itemId], amount):
		get_node("/root/Console").write_line("picked up: " + str(amount) + " " + Global.allItems[itemId].get_name())
		remove_child(child)
		child.queue_free()
	else:
		get_node("/root/Console").write_line("Couldn't pick up item")
		