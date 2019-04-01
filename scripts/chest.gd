extends Node2D

signal on_area_entered(name, inventory)
signal on_area_exited(name)

const Inventory = preload("res://scripts/inventory/Inventory.gd")


var _inventory = {}
export(String, "smallChest", "mediumChest", "bigChest") var _type = "smallChest"

func _ready():
	pass

func init(invPrefab):
	
	for i in range(
	
	_inventory.update_inventory_size(12)
	_inventory.update_weight_enabled(false)
	_inventory._update_max_weight(999999)
	_add_item(0)

func _on_area_body_entered(body):
	emit_signal("on_area_entered", name, _inventory)

func _on_area_body_exited(body):
	emit_signal("on_area_exited", name)

func _add_item(itemId):
	_inventory.add_item(Global.allItems[itemId])
	

