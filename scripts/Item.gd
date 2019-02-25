class_name Item


enum ItemType {
	WEAPON_MELEE,
	WEAPON_RANGED,
	POTION,
	ARMOR,
	TOME
}

static func get_type_from_name(itemTypeName : String):
	match (itemTypeName):
		"WEAPON_MELEE":
			return ItemType.WEAPON_MELEE
		"WEAPON_RANGED":
			return ItemType.WEAPON_RANGED
		"POTION":
			return ItemType.POTION
		"ARMOR":
			return ItemType.ARMOR
		"TOME":
			return ItemType.TOME
		_:
			print("unkown item type!")
			return "UNKOWN_ITEM_TYPE"
	

static func get_type_name(itemType) -> String:
	match (itemType):
		ItemType.WEAPON_MELEE:
			return "WEAPON_MELEE"
		ItemType.WEAPON_RANGED:
			return "WEAPON_RANGED"
		ItemType.POTION:
			return "POTION"
		ItemType.ARMOR:
			return "ARMOR"
		ItemType.TOME:
			return "TOME"
		_:
			print("unkown item type!")
			return "UNKOWN_ITEM_TYPE"

	
	
var _id : int = -1
var _name : String
var _description : String
var _value : int
var _weight : float

var _textureRegion : Rect2
var _texturePath : String

# enums
var _type

# Dicts
var _effects
var _requirements

var _stackSize : int = 1
var _stackable : bool
var _usable : bool
var _discardable : bool 
var _sellable : bool
var _consumable : bool 


func _init(id, name, type, weight, value, effects, requirements, description, texturePath, textureRegion, \
			stackSize, stackable = false, usable = false, discardable = true, sellable = true, consumable = false):
	_id = id
	_name = name
	_type = type
	_value = value
	_weight = weight
	_effects = effects
	_requirements = requirements
	_description = description
	_texturePath = texturePath
	_usable = usable
	_discardable = discardable
	_sellable = sellable
	_consumable = consumable
	_stackable = stackable
	_stackSize = stackSize
	_textureRegion = Rect2(textureRegion["x"], textureRegion["y"], textureRegion["w"], textureRegion["h"])
	
	
func get_id() -> int:
	return _id

func get_name() -> String:
	return _name
	
func get_type() -> String:
	return get_type_name(_type)

func get_weight() -> float:
	return _weight
	
func get_value() -> int:
	return _value
	
func get_effects() -> Dictionary:
	return _effects

func get_requirements() -> Dictionary:
	return _requirements
	
func get_description() -> String:
	return _description
	
func get_texture_path() -> String:
	return _texturePath

func get_texture_region() -> Rect2:
	return _textureRegion
	
func get_stack_size() -> int:
	return _stackSize
	
func is_stackable() -> bool:
	return _stackable
	
func is_usable() -> bool:
	return _usable
	
func is_discardable() -> bool:
	return _discardable
	
func is_consumable() -> bool:
	return _consumable
	
func is_sellable() -> bool:
	return _sellable

