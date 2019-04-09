"""
This class is used as an wrapper for
the slot, the item, requirements and the amount of the items
"""
extends Node

const ItemSlot = preload("res://scripts/inventory/ItemSlot.gd")
const SlotRequirement = preload("res://scripts/inventory/SlotRequirement.gd")

const itemSlotPrefab = preload("res://scenes/inventory/ItemSlot.tscn")

# move this to global, don't load atlas texture for each inventory
var _atlasTexture = Global.itemAtlas

var _item = null
var _slot : ItemSlot = null #: TextureButton
var _amount = 0
var _slotRequirements = {} # level, class, type of item
var _slotTypeRequirements : Array # ItemTypes

func _init(id):
	var slot = ItemSlot.new()
	_slot = (itemSlotPrefab.instance() as ItemSlot)
	#print("slotname: " + id)
	_slot.init(id)
	#_slot.set_amount(0)
	#_slot = ItemSlotPrefab.instance()
	pass

func set_slot_types(types : Array):
	_slotTypeRequirements = types

func accepts_slot_type(type) -> bool:
	if _slotTypeRequirements.empty():
		return true
	return _slotTypeRequirements.has(type)

func get_slot_types() -> Array:
	return _slotTypeRequirements

func set_amount(amount : int):
	_amount = amount
	_slot.set_amount(amount)

# if amount = 0, delete whole slot, else n>0 remove n items
func remove_item(amount : int = 0):
	if amount == 0:
		_slot.set_item_texture(null)
		_item = null
		_amount = 0
	else:
		_amount -= amount
		if _amount <= 0:
			_amount = 0
			_item = null
			_slot.set_item_texture(null)
	_slot.set_amount(_amount)

func set_item(item, amount):
	_item = item
	_amount = amount
	_slot.set_amount(_amount)

	var atls = AtlasTexture.new()
	if item == null:
		atls = null
	else:
		atls.atlas = _atlasTexture
		atls.region = _item.get_texture_region()
		atls.margin = Rect2(0,3,0,0)
	_slot.set_item_texture(atls)

func get_item():
	return _item

func get_amount() -> int:
	return _amount

func get_weight() -> float:
	if _item != null:
		return _item.get_weight() * get_amount()
	else:
		return 0.0

func set_selected():
	_slot.set_selected()

func set_unselected():
	_slot.set_unselected()

func add_slot_requirement(requirementType, value):
	_slotRequirements[SlotRequirement.get_requirement_name(requirementType)] = value

func has_slot_requirements() -> bool:
	return _slotRequirements.size() > 0

func get_slot_requirements() -> Dictionary:
	return _slotRequirements
