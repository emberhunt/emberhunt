"""
This is a inventory that only can be used
by including it in an inventory system

- use EITHER:
	1. Gridcontainer with colums and inventorySize export var
	2. OR custom container, where you have to instanciate the 
	   item slots yourself 
"""
tool
extends Control

# signaled, when pressed or released
signal on_slot_toggled(is_pressed, _selected, inventoryName)

# types

const Item = preload("res://scripts/Item.gd")
const ItemSlot = preload("res://scripts/ItemSlot.gd")
const SlotRequirement = preload("res://scripts/SlotRequirement.gd")
const Character = preload("res://scripts/character.gd")


const itemSlotPrefab = preload("res://scenes/ItemSlot.tscn")

# move this to global, don't load atlas texture for each inventory
const _atlasTexture = preload("res://assets/inventory/items.png")
#const _slotBackground = preload("res://assets/inventory/slotBackground.png")

"""
This class is used as an wrapper for 
the slot, the item, requirements and the amount of the items
"""
class Slot:
	const ItemSlot = preload("res://scripts/ItemSlot.gd")
	
	var _item : Item = null
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
		_slot.set_amount(_amount)	
			
		
	func set_item(item : Item, amount):
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
		
	func get_item() -> Item:
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
		


# vars

onready var itemSlots = $slots
onready var weightLabel = $weightLabel


# the name should be something like: "playerinventory", "chest" or "merchant"
export(String) var inventoryDisplayName = "inventory" setget update_inventory_name
export(int) var inventorySize = 0 setget update_inventory_size
export(int) var columns = 4 setget update_inventory_columns
export(bool) var weightEnabled = false setget update_weight_enabled
export(float) var maxWeight = -1 setget _update_max_weight
	

func update_inventory_size(size : int):
	if size < 0:
		return
	
	if has_node("slots") and $slots != null:
		if not $slots.is_class("GridContainer"):
			inventorySize = 0
			return
		
		if $slots.get_child_count() != inventorySize:
			_slots.clear()
			for i in range($slots.get_child_count()):
				$slots.get_child(0).free()
	
			inventorySize = 0
	
	if size > inventorySize: # create more slots
		for i in range(size - inventorySize):
			add_empty_slot()
	elif size < inventorySize: #remove last slots
		for i in range(inventorySize - size):
			remove_last_slot()
	
	inventorySize = size
	

func _update_max_weight(newMax):
	maxWeight = newMax
	_update_weight()

func update_weight_enabled(enable : bool):
	weightEnabled = enable
	if has_node("weightLabel") and $weightLabel != null:
		$weightLabel.set_visible(enable)
	
func update_inventory_name(name : String):
	if has_node("nameBackground/name") and $nameBackground/name != null:
		$nameBackground/name.text= name
		inventoryDisplayName = name

func update_inventory_columns(cols : int):
	if cols < 0:
		return
	# set colums to 0 for custom layout
	if has_node("slots") and $slots != null:
		if not $slots.is_class("GridContainer"):
			columns = 0
			return
		else:
			columns = cols
			$slots.columns = columns


# how much can this inventory carry, negative means, no limit

var _currentWeight = 0.0


# class Slot, contains all available slots
var _slots = []
# contains string ids of all registered ids
#var _registeredSlotNames = []

# this will be assigned by the inventory system, -1 means it's not opened/not in an inventory system
# inventoryId should be the unique player id
var _id

# arraypos = id, 
var _allItems = []
# to get items by names
var _allItemNames = {}

var _lastSelected = -1
var _selected = -1

func _ready():
	set_process(false)
	set_process_input(true)
	
	$nameBackground/name.set_text(inventoryDisplayName)
	_id = self.name
	
	_load_all_items()
	
	# set colums to 0 for custom layout
	if itemSlots is GridContainer:
		pass
#	if columns > 0 and itemSlots is GridContainer:
#		itemSlots.columns = columns
#
#		for i in range(inventorySize):
#			var textureRect = TextureRect.new()
#			textureRect.texture = _slotBackground
#			var emptySlot = Slot.new(inventoryName + str(i))
#			if i == 0:
#				emptySlot.add_slot_requirement(SlotRequirement.SlotRequirement.CLASS, \
#						Character.get_character_type_name(Character.CharacterType.KNIGHT))
#				emptySlot.set_slot_types([Item.get_type_name(Item.ItemType.GREAT_SWORD)])
#			add_slot(emptySlot)
#
	else:
		inventorySize = itemSlots.get_child_count()
		print("inventorySize: " + str(inventorySize))
		for i in range(inventorySize):
			itemSlots.get_child(i).init(i)
	
		add_existing_slots()
		#register_existing_slots()
		
	
#func register_slot(name : String, slot : Slot):
#	_registeredSlotNames.append(name)
#	_slots[name] = slot
	

#func remove_all_registered_slots():
#	for i in range(_registeredSlotNames.size()):
#		_slots.erase(_registeredSlotNames[i])
	
	
func _get_selected_item() -> ItemSlot:
	return _slots[_selected]._item
	
func _input(event):
	if not is_visible() or Global.paused:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			pass
		else:
			if _lastSelected != -1:
				_slots[_lastSelected].set_unselected()

#			# release
#			#print('last ' + str(_lastSelected))
#			#print('cur ' + str(_selected))
#			_isHolding = false
#			#itemList.unselect(_selected)
#			_slots[str(_selected)].set_selected()
#
#			# change item slots
#			var closest = itemList.get_item_at_position(event.position, true)
#			if closest != _selected and _selected != -1:
#				#print('release at ' + str(closest))
#				if closest != -1 and _itemSlots[str(_selected)] != null:
#					_swap_items(_selected, closest)


# this fills all loaded items from the file to _items
func _load_all_items():
	var data : Dictionary = load_inventory("res://assets/inventory/PlayerInventory.json")
	
	for i in range(data.size()):
		var itemData= data[str(i)]
		#print(itemData["type"])
		#print(Item.get_type_from_name(itemData["type"]))
		var newItem = Item.new(
				i,
				itemData["name"], 
				Item.get_type_from_name(itemData["type"]),
				itemData["weight"],
				itemData["value"],
				itemData["effects"],
				itemData["requirements"],
				itemData["description"],
				itemData["texture_path"],
				itemData["texture_region"],
				itemData["slots_use"],
				itemData["stack_size"],
				itemData["stackable"],
				itemData["usable"],
				itemData["discardable"],
				itemData["sellable"],
				itemData["consumable"]
				)
				
		_allItems.append(newItem)
		_allItemNames[newItem.get_name()] = newItem


func can_carry_items(item : Item, amount : int = 1) -> bool:
	if _currentWeight + (item.get_weight() * float(amount)) > maxWeight:
		return false
	return true
	

func get_carry_weight() -> float:
	return _currentWeight
	

func get_remainging_carry_weight() -> float:
	return maxWeight - _currentWeight
	

func get_max_carry_weight() -> float:
	return maxWeight
	
	
# register slots if you want to add slots that already exist in the editor
func add_existing_slots():
	#print("current slot size = " + str(_slots.size()))
	for i in range(inventorySize):
		var newSlotIndex = _slots.size()
		var emptySlot = Slot.new(newSlotIndex)
		_slots.append(emptySlot)
		_slots[newSlotIndex]._slot = itemSlots.get_child(i)
		_slots[newSlotIndex]._slot.connect("on_slot_pressed", self, "_on_slot_pressed") 
		_slots[newSlotIndex]._slot.connect("on_slot_released", self, "_on_slot_released") 


func add_empty_slot():
	if not (has_node("slots") and $slots != null):
		return 
	var newSlotIndex = _slots.size()
	#print(newSlotIndex)
	var emptySlot = Slot.new(newSlotIndex)
#	if _slots.size() == 0:
#		emptySlot.add_slot_requirement(SlotRequirement.SlotRequirement.CLASS, \
#				Character.get_character_type_name(Character.CharacterType.KNIGHT))
#		emptySlot.set_slot_types([Item.get_type_name(Item.ItemType.GREAT_SWORD)])
	
	_slots.append(emptySlot)
	$slots.add_child(_slots[newSlotIndex]._slot)
	
	_slots[newSlotIndex]._slot.connect("on_slot_pressed", self, "_on_slot_pressed") 
	_slots[newSlotIndex]._slot.connect("on_slot_released", self, "_on_slot_released") 
	
	#print("added empty slot: " + newSlotIndex)
	#print("with slot name: " + _slots[newSlotIndex]._slot.name)


func remove_last_slot():
	if not _slots.empty():
		var lastKey := str(_slots.keys()[_slots.size() - 1])
		var lastChild := str($slots.get_child($slots.get_child_count() - 1).name)
		#print("removing last: " + lastKey  + " == " + lastChild)
		remove_slot(lastKey)


func remove_slot(slotId):
	if not (has_node("slots") and $slots != null):
		return 
	
	var deleteSlotName = slotId
	var deleteNodeName = _slots[slotId]._slot.name
	
	#print("delete slot name: " + deleteSlotName)
	#print("delete node name: " + deleteNodeName)
	#print("delete node path name: " + deleteNodePath)
	if not $slots.has_node(deleteNodeName):
		for i in range($slots.get_child_count()):
			print($slots.get_child(i).name)
	
	$slots.remove_child($slots.get_node(deleteNodeName))
	_slots.erase(slotId)



func remove_item(slotId : int, amount : int = 0) -> Item:
	var item = get_slot(slotId)._item
	add_weight(-item.get_weight())
	get_slot(slotId).remove_item(amount)
	return item


# add item to inventory
#return false if couldn't add item to inv
func add_item(item : Item, amount : int = 1) -> bool:
	# search if same item exists and is stackable,
	# and if it is stackable, is it max stacked
	
	if maxWeight > 0.0 and item.get_weight() + _currentWeight > maxWeight:
		#print('too weak to carry more')
		return false
	
	for i in range(_slots.size()):
		var currentSlot = get_slot(i)
		var curItem = get_slot(i)._item
		if currentSlot._item != null:
			if curItem.get_id() == item.get_id() and curItem.is_stackable():
				if currentSlot.get_amount() < curItem.get_stack_size():
					#print("item id of stackable: " + str(currentSlot.get_amount()))
					currentSlot.set_amount(currentSlot.get_amount() + 1)
					_currentWeight += item.get_weight()
					_update_weight()
					return true

	# if not stackable/not exist/full stack then add to new slot
	var freeId = _get_next_free_slot_id()
	#print(freePos)
	if freeId == -1:
		return false

	#print("free at: " + str(freePos))
	_slots[freeId].set_item(item, amount)
	_currentWeight += item.get_weight()
	_update_weight()
	return true

	
# json file
func load_inventory(fileName : String) -> Dictionary:
	var file = File.new()
	file.open(fileName, file.READ)
	var dataText = file.get_as_text()
	file.close()
	var data = JSON.parse(dataText)
	
	if data.error != OK:
		print("Problems loading " + fileName + " (in Inventory.gd)")
		return {}
	
	return data.result


func set_item(id, item, amount = 1):
	var tempItem = _slots[id].set_item(item, amount)
	
	
func get_item(id):
	return _slots[id].get_item() 
	

func set_item_amount(id, amount):
	_slots[id].set_amount(amount)


func get_item_amount(id):
	return _slots[id].get_amount()
	

func set_slot_selected(id):
	_slots[id].set_selected()
	
func set_slot_unselected(id):
	_slots[id].set_unselected()


func set_weight(weight : float):
	_currentWeight = weight
	_update_weight()

func add_weight(weight : float):
	_currentWeight += weight
	_update_weight()

func get_weight() -> float:
	return _currentWeight


func get_item_by_id(id : int) -> Item:
	return _allItems[id]


func _get_item_by_name(name : String) -> Item:
	return _allItemNames[name]
	
func get_slot_size():
	return _slots.size() 


func get_slots() -> Array:
	return _slots
	
func get_item_at_slot(slotId : int) -> Item:
	return _slots[slotId]._item
	

func get_slot(pos : int) -> Slot:
	return _slots[pos]


func _get_next_free_slot_id():
	for i in range(inventorySize):
		if get_slot(i).get_item() == null:
			return i
	return -1
	
	
func get_selected_slot() -> Slot:
	return _slots[_selected]


func get_selected_item() -> Item:
	return _slots[_selected]._item
	
	
func get_last_selected_slot() -> Slot:
	return _slots[_lastSelected]
	

func get_slot_weight(id):
	return _slots[id].get_weight()
	
	
func get_last_selected_item() -> Item:
	return _slots[_lastSelected]._item
	
	
func get_id() -> String:
	return _id
	
	
# this should only be set 
func _set_id(id):
	_id = id


func get_display_name() -> String:
	return inventoryDisplayName


func get_item_id_by_name(itemName : String) -> String:
	#print("get_item_id_by_name in inventory")
	for i in range(_allItems):
		if itemName == _allItems[i].get_name():
			return _allItems[i]
			
	# if item name not found
	printerr("couldn't find item with name: " + itemName)
	return ""


func _update_weight():
	if has_node("weightLabel") and $weightLabel != null:
			$weightLabel.text = str(_currentWeight) + " / " + str(maxWeight)


func _on_slot_released(index):
	if not is_visible() or Global.paused:
		return
		
	_lastSelected = _selected
	_selected = index
	#print("released: " + str(index))
	
	emit_signal("on_slot_toggled", false, _selected, _id)
	

func _on_slot_pressed(index):
	if not is_visible() or Global.paused:
		return
		
	_lastSelected = _selected
	_selected = index
	#print("selected: " + str(index))
	emit_signal("on_slot_toggled", true, _selected, _id)
