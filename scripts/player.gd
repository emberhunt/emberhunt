extends "res://scripts/character.gd"

class_name Player

const InventorySystem = preload("res://scripts/InventorySystem.gd")

var inventory : InventorySystem

func _init():
	inventory = inventorySystem.new()
	
	_set_properties()
	print(get_property(PropertyType.CLASS))
	

func _set_properties():
	set_property(PropertyType.CURRENT_HEALTH, 50)
	set_property(PropertyType.MAX_HEALTH, 100)
	set_property(PropertyType.CURRENT_MANA, 50)
	set_property(PropertyType.MAX_MANA, 100)
	set_property(PropertyType.STRENGTH, 1)
	set_property(PropertyType.AGILITY, 1)
	set_property(PropertyType.MAGIC, 1)
	set_property(PropertyType.LUCK, 1)
	set_property(PropertyType.PHYSICAL_DEFENSE, 1)
	set_property(PropertyType.MAGIC_RESISTANCE, 1)
	set_property(PropertyType.CARRY_WEIGHT, 100.0)
	
	set_property(PropertyType.CLASS, get_character_name(CharacterType.KNIGHT))
	set_property(PropertyType.LEVEL, 1)

