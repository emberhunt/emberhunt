extends Node2D

signal on_area_entered(name, inventory)
signal on_area_exited(name)

var _inventory = {}
export(String, "smallChest", "mediumChest", "bigChest") var _type = "smallChest"

func _ready():
	_add_item(0, 1)
	_add_item(1, 1)

func init(invPrefab):
	pass

func _on_area_body_entered(body):
	emit_signal("on_area_entered", _type, _inventory)

func _on_area_body_exited(body):
	emit_signal("on_area_exited", _type)

func _add_item(itemId, amount):
	_inventory[_inventory.size()] = { "item_id" : itemId, "amount" : amount}

