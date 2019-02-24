"""
- each entity has a unique id 
"""
extends Node2D

class_name Entity

enum PropertyType {
	# general
	ID,
	
	# character
	CURRENT_HEALTH,
	MAX_HEALTH,
	CURRENT_MANA,
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

var properties = {}


func _ready():
	# TODO: add autoload script to get ids, probably by server
	var uid = 0 # get_next_id()
	
	print("entity[" + str(uid) + "]")
	set_property(PropertyType.ID, uid)
	
	
func get_properties() -> Dictionary:
	return properties


func has_property(propertyType) -> bool:
	return properties.has(propertyType)
	
	
func set_property(propertType, value):
	properties[get_property_name(propertType)] = value
	
	
func get_property_name(propertyType):
	match (propertyType):
		PropertyType.ID:
			return "uid" 
			
		PropertyType.MAX_HEALTH:
			return "healthMax" 
		PropertyType.CURRENT_HEALTH:
			return "healthCurrent" 
		PropertyType.CURRENT_MANA:
			return "manaCurrent" 
		PropertyType.MAX_MANA:
			return "manaMax" 
		PropertyType.STRENGTH:
			return "strength"
		PropertyType.AGILITY:
			return "agility" 
		PropertyType.MAGIC:
			return "magic" 
		PropertyType.LUCK:
			return "luck" 
		PropertyType.PHYSICAL_DEFENSE:
			return "physicalDefense" 
		PropertyType.MAGIC_RESISTANCE:
			return "magicResistance" 
			
		PropertyType.LEVEL:
			return "level"
		PropertyType.CLASS:
			return "class"
		_:
			print("coudln't find propertyType: " + str(propertyType))
			return ""
			
			
func get_property(propertyType):
	return properties[get_property_name(propertyType)] 

