extends Node2D


const Inventory = preload("res://scripts/inventory/Inventory.gd")

export(NodePath) var inventory = "/root/FortressOfTheDark/GUI/CanvasLayer/inventorySystem"

var _mainInv : Inventory = null


func _ready():
	for i in range(get_child_count()):
		get_child(i).connect("on_pickup_range_entered", self, "add_to_inventory")


func init(inventorySystemPath):
	_mainInv = get_node(inventorySystemPath)
	if _mainInv == null:
		get_node("/root/Console").write_line("[color=red]ERROR:[/color] couldn't find inventory!")
	_mainInv.connect("on_item_inventory_swapped", self, "save_items")


func add_to_inventory(child, itemId, amount):
	if _mainInv.get_inventory().add_item(Global.allItems[itemId], amount):
		get_node("/root/Console").write_line("picked up: " + str(amount) + " " + Global.allItems[itemId].get_name())
		remove_child(child)
		child.queue_free()
	else:
		get_node("/root/Console").write_line("Couldn't pick up item")
		