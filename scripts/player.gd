extends "res://scripts/character.gd"



func _ready():
	_set_properties()

func _set_properties():
	set_property(PropertyType.HEALTH, 50)
	set_property(PropertyType.MAX_HEALTH, 100)
	set_property(PropertyType.MANA, 50)
	set_property(PropertyType.MAX_MANA, 100)
	set_property(PropertyType.STRENGTH, 1)
	set_property(PropertyType.AGILITY, 1)
	set_property(PropertyType.MAGIC, 1)
	set_property(PropertyType.LUCK, 1)
	set_property(PropertyType.PHYSICAL_DEFENSE, 1)
	set_property(PropertyType.MAGIC_RESISTANCE, 1)
	set_property(PropertyType.CARRY_WEIGHT, 100.0)
	
	set_property(PropertyType.CLASS, get_character_type_name(CharacterType.KNIGHT))
	set_property(PropertyType.LEVEL, 1)

