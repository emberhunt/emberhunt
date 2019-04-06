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

func get_property_name(propertyType):
	match (propertyType):
		PropertyType.ID:
			return "uid" 
			
		PropertyType.GOLD:
			return "gold" 		
		PropertyType.EXPERIENCE:
			return "experience" 
			
		PropertyType.MAX_HEALTH:
			return "healthMax" 
		PropertyType.HEALTH:
			return "health" 
		PropertyType.MANA:
			return "mana" 
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
			
		PropertyType.CARRY_WEIGHT:
			return "carryWeight"
			
		PropertyType.LEVEL:
			return "level"
		PropertyType.CLASS:
			return "class"
		_:
			print("coudln't find propertyType: " + str(propertyType))
			return ""
			
			
