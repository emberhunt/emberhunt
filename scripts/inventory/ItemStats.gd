class_name Item


enum ItemType {
	# Weapons
	SPEAR,
	SWORD,
	GREAT_SWORD,
	DAGGER,
	LANCE,
	MACE,
	SHORT_BOW,
	LONG_BOW,
	HARP_BOW,
	SHURIKEN,
	THROWING_DAGGER,
	STAVE,
	SCROLL,
	WAND,
	PRIMAL_FOCUS,
	
	# Offhand
	SHIELD,
	BANNER,
	TOWER_SHIELD,
	WITHERED_HEAD,
	QUIVER,
	CRYSTAL_SHARD,
	ORB,
	TRAP,
	NATRUE_RELIC,
	DIVINE_RELIC,
	ARROW,
	
	# Armor
	ARMOR_CHEST,
	ARMOR_HELMET,
	ARMOR_LEG,
	
	# Consumable
	POTION
}

const _itemTypes = {
	ItemType.SPEAR : "SPEAR",
	ItemType.SWORD : "SWORD",
	ItemType.GREAT_SWORD : "GREAT_SWORD",
	ItemType.DAGGER : "DAGGER",
	ItemType.LANCE : "LANCE",
	ItemType.MACE : "MACE",
	ItemType.SHORT_BOW : "SHORT_BOW",
	ItemType.LONG_BOW : "LONG_BOW",
	ItemType.HARP_BOW : "HARP_BOW",
	ItemType.SHURIKEN : "SHURIKEN",
	ItemType.THROWING_DAGGER : "THROWING_DAGGER",
	ItemType.SCROLL : "SCROLL",
	ItemType.WAND : "WAND",
	ItemType.PRIMAL_FOCUS : "PRIMAL_FOCUS",
	
	ItemType.SHIELD : "SHIELD",
	ItemType.BANNER : "BANNER",
	ItemType.TOWER_SHIELD : "TOWER_SHIELD",
	ItemType.WITHERED_HEAD : "WITHERED_HEAD",
	ItemType.QUIVER : "QUIVER",
	ItemType.CRYSTAL_SHARD : "CRYSTAL_SHARD",
	ItemType.ORB : "ORB",
	ItemType.TRAP : "TRAP",
	ItemType.NATRUE_RELIC : "NATRUE_RELIC",
	ItemType.DIVINE_RELIC : "DIVINE_RELIC",
	
	ItemType.ARMOR_CHEST : "ARMOR_CHEST",
	ItemType.ARMOR_HELMET : "ARMOR_HELMET",
	ItemType.ARMOR_LEG : "ARMOR_LEG",
	
	ItemType.POTION : "POTION"
}

static func get_type_from_name(itemTypeName : String):
	for type in _itemTypes.keys():
		if _itemTypes[type] == itemTypeName:
			return type
	
	printerr("couldn't find item name")
	assert(true)
	return null
	

static func get_type_name(itemType) -> String:
	for name in _itemTypes.values():
		if name == _itemTypes[itemType]:
			return name
	
	printerr("couldn't find item name")
	assert(true)
	return ""

	
	
var _id : int = -1
var _name : String
var _description : String
var _value : int
var _weight : float

var _textureRegion : Rect2
var _texturePath : String

var _slotsUse # for 1 or 2 handed weapon

# enums
var _type

# Dicts
var _effects
var _requirements
var _stats # currently only used for weapons


var _stackSize : int = 1
var _stackable : bool
var _usable : bool
var _discardable : bool 
var _sellable : bool
var _consumable : bool 


func _init(id, name, type, weight, value, effects, requirements, stats, description, texturePath, textureRegion, \
			slotsUse, stackSize, stackable = false, usable = false, discardable = true, sellable = true, consumable = false):
	_id = id
	_name = name
	_type = type
	_value = value
	_weight = weight
	_effects = effects
	_requirements = requirements
	_stats = stats
	_description = description
	_texturePath = texturePath
	_usable = usable
	_discardable = discardable
	_sellable = sellable
	_consumable = consumable
	_slotsUse = slotsUse
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
	
func get_stats() -> Dictionary:
	return _stats
	
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

