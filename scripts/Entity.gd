"""
- each entity has a unique id 
"""
extends Node2D

signal property_changed

class_name Entity

enum PropertyType {
	# general
	ID,
	
	GOLD,
	EXPERIENCE,
	
	# character
	HEALTH,
	MAX_HEALTH,
	MANA,
	MAX_MANA,
	STRENGTH,
	AGILITY,
	MAGIC,
	LUCK,
	PHYSICAL_DEFENSE,
	MAGIC_RESISTANCE,
	
	CARRY_WEIGHT,
	
	LEVEL,
	CLASS
}

const _propertyDict = {
	# general
	PropertyType.ID : "id",
	
	PropertyType.GOLD : "gold",
	PropertyType.EXPERIENCE : "experience",
	
	# character
	PropertyType.HEALTH : "health",
	PropertyType.MAX_HEALTH : "max_health",
	PropertyType.MANA : "mana",
	PropertyType.MAX_MANA : "max_mana",
	PropertyType.STRENGTH : "strength",
	PropertyType.AGILITY : "agility",
	PropertyType.MAGIC : "magic",
	PropertyType.LUCK : "luck",
	PropertyType.PHYSICAL_DEFENSE : "physical_defense",
	PropertyType.MAGIC_RESISTANCE : "magic_resistance",
	
	PropertyType.CARRY_WEIGHT : "weight",
	
	PropertyType.LEVEL : "level",
	PropertyType.CLASS : "class"
}

var _properties = {}

func _ready():
	# TODO: add autoload script to get ids, probably by server
	var uid = 0 # get_next_id()
	
	#print("entity[" + str(uid) + "]")
	set_property(PropertyType.ID, uid)
	
func get_properties() -> Dictionary:
	return _properties

func has_property(propertyType) -> bool:
	return _properties.has(propertyType)
	
func set_property(propertType, value):
	_properties[get_property_name(propertType)] = value
	emit_signal("property_changed", _properties)
	
func get_property(propertyType):
	return _properties[get_property_name(propertyType)] 

func get_property_by_name(propertyType):
	for i in range(_properties.size()):
		if _propertyDict.values()[i] == propertyType:
			return _propertyDict.keys()[i]
	DebugConsole.error("Couldn't find property type by name: " + str(propertyType))
	return null
	
func get_property_name(propertyType):
	if _propertyDict.has(propertyType):
		return _propertyDict[propertyType]
	DebugConsole.error("Couldn't find property type: " + str(propertyType))
	return null
