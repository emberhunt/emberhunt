extends "res://scripts/character.gd"

class_name Player

var inventory = preload("res://scripts/Inventory.gd").new()

func _init():
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
	
	set_property(PropertyType.CLASS, get_character_type(CharacterType.KNIGHT))
	set_property(PropertyType.LEVEL, 1)
