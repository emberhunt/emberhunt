"""
This is a inventory that only can be used
by including it in an inventory system
"""
tool
extends Control

# signaled, when pressed or released
signal on_slot_toggled(is_pressed, _selected, inventoryName)


const Item = preload("res://scripts/Item.gd")
const ItemSlot = preload("res://scripts/ItemSlot.gd")
const SlotRequirement = preload("res://scripts/SlotRequirement.gd")
const Character = preload("res://scripts/character.gd")


const itemSlotPrefab = preload("res://scenes/ItemSlot.tscn")

# move this to global, don't load atlas texture for each inventory
const _atlasTexture = preload("res://assets/inventory/items.png")
const _slotBackground = preload("res://assets/inventory/slotBackground.png")
const _emptySlot = preload("res://assets/inventory/empty_slot.png")

"""
This class is used as an wrapper for 
the slot, the item, requirements and the amount of the items
"""
class Slot:
	var _item : Item = null
	var _slot #: TextureButton
	var _amount = 0
	var _slotRequirements = {} # level, class, type of item
	var _slotTypeRequirements : Array # ItemTypes

	func _init(id : String):
		_slot = itemSlotPrefab.instance()
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


onready var itemSlots = $background/slots
onready var weightLabel = $background/weightLabel

# this will be assigned by the inventory system, -1 means it's not opened/not in an inventory system
# inventoryId should be the unique player id
var inventoryId : int = -1
# the name should be something like: "playerinventory", "chest" or "merchant"
export(String) var inventoryName = "inventory" setget update_inventory_name
export(int) var maxInventorySize = 8
export(int) var columns = 4 setget update_inventory_columns
export(bool) var weightEnabled = false setget update_weight_enabled
export(float) var maxWeight = -1 setget _update_max_weight

func _update_max_weight(newMax):
	maxWeight = newMax
	_update_weight()

func update_weight_enabled(enable : bool):
	weightEnabled = enable
	if has_node("background/weightLabel"):
		if $background/weightLabel != null:
			$background/weightLabel.set_visible(enable)
	
func update_inventory_name(name : String):
	if not Engine.editor_hint:
		return
	
	if has_node("background/weightLabel"):
		if $background/weightLabel != null:
			$background/nameBackground/name.text= name
			inventoryName = name

func update_inventory_columns(cols : int):
	# set colums to 0 for custom layout
	if $background/slots.is_class("GridContainer"):
		columns = cols
		$background/slots.columns = columns


# how much can this inventory carry, negative means, no limit

var _currentWeight = 0.0


# class Slot, contains all available slots
var _slots = {}
# contains string ids of all registered ids
var _registeredSlotNames = []

# arraypos = id, 
var _allItems = []
# to get items by names
var _allItemNames = {}

var _lastSelected : String = ""
var _selected : String = ""

func _ready():
	set_process(false)
	set_process_input(true)
	
	$background/nameBackground/name.set_text(inventoryName)
	inventoryName = self.name	
	
	_load_all_items()
	
	# set colums to 0 for custom layout
	if columns > 0 and itemSlots is GridContainer:
		itemSlots.columns = columns

		for i in range(maxInventorySize):
			var textureRect = TextureRect.new()
			textureRect.texture = _slotBackground
			var emptySlot = Slot.new(inventoryName + str(i))
			if i == 0:
				emptySlot.add_slot_requirement(SlotRequirement.SlotRequirement.CLASS, \
						Character.get_character_type_name(Character.CharacterType.KNIGHT))
				emptySlot.set_slot_types([Item.get_type_name(Item.ItemType.GREAT_SWORD)])
			add_slot(emptySlot)

	else:
		maxInventorySize = itemSlots.get_child_count()

		for i in range(maxInventorySize):
			itemSlots.get_child(i).init(inventoryName + str(i))

		register_existing_slots()
		
	
func register_slot(name : String, slot : Slot):
	_registeredSlotNames.append(name)
	_slots[name] = slot
	

func remove_all_registered_slots():
	for i in range(_registeredSlotNames.size()):
		_slots.erase(_registeredSlotNames[i])
	
	
func _get_selected_slot() -> ItemSlot:
	return _slots[_selected]._item
	
func _input(event):
	if not get_parent().is_visible() or Global.paused:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			pass
		else:
			if _lastSelected != "":
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
	
	
# register slots if you want to add slots that already exist in the editor
func register_existing_slots():
	for i in range(maxInventorySize):
		var newSlotIndex = inventoryName + str(_slots.size())
		var emptySlot = Slot.new(newSlotIndex)
		_slots[newSlotIndex] = emptySlot
		_slots[newSlotIndex]._slot = itemSlots.get_child(i)
		_slots[newSlotIndex]._slot.connect("on_slot_pressed", self, "_on_slot_pressed") 
		_slots[newSlotIndex]._slot.connect("on_slot_released", self, "_on_slot_released") 

	
func add_slot(slot : Slot):
	#print("adding slot")
	var newSlotIndex = inventoryName + str(_slots.size())
	_slots[newSlotIndex] = slot
	$background/slots.add_child(_slots[newSlotIndex]._slot)

	_slots[newSlotIndex]._slot.connect("on_slot_pressed", self, "_on_slot_pressed") 
	_slots[newSlotIndex]._slot.connect("on_slot_released", self, "_on_slot_released") 


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
	if freeId == "":
		return false

	#print("free at: " + str(freePos))
	_slots[freeId].set_item(item, amount)
#	var atls = AtlasTexture.new()
#	atls.atlas = _atlasTexture
#	atls.region = item.item.get_texture_region()
#	atls.margin = Rect2(0,3,0,0)
#	itemList.set_item_tooltip(freePos, item.item.get_description())
#	itemList.set_item_tooltip_enabled(freePos, true)
#	itemList.set_item_icon(freePos, atls)
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

	
func swap_selected():
	swap_items(_selected, _lastSelected)
	
	
func swap_items(idx1 : String, idx2 : String): 
	var tempItem = _slots[idx1].get_item()
	var amount = _slots[idx1].get_amount()
	
	_slots[idx1].set_item(_slots[idx2].get_item(), _slots[idx2].get_amount())
	_slots[idx2].set_item(tempItem, amount)
	

func set_weight(weight : float):
	_currentWeight = weight
	_update_weight()

func add_weight(weight : float):
	_currentWeight += weight
	_update_weight()

func get_weight() -> float:
	return _currentWeight


func _get_item_by_id(id : int) -> Item:
	return _allItems[id]


func _get_item_by_name(name : String) -> Item:
	return _allItemNames[name]
	

func get_item(id : int) -> Item:
	# ItemSlot.new(item, amount)
	#return ItemSlot.new(_get_item_by_id(id), 1)
	return _get_item_by_id(id) 


func get_slot_size():
	return _slots.size() - _registeredSlotNames.size()


func get_slots() -> Dictionary:
	return _slots
	
func get_item_at_slot(slotId : int) -> Item:
	return _slots[str(slotId)]._item
	

func get_slot(id : int) -> Slot:
	return _slots[inventoryName + str(id)]


func _get_next_free_slot_id() -> String:
	for i in range(maxInventorySize):
		if _slots[inventoryName + str(i)].get_item() == null:
			return inventoryName + str(i)
	return ""
	
	
func get_selected_slot() -> Slot:
	return _slots[_selected]


func get_selected_item() -> Item:
	return _slots[_selected]._item
	
	
func get_last_selected_slot() -> Slot:
	return _slots[_lastSelected]


func get_last_selected_item() -> Item:
	return _slots[_lastSelected]._item


func get_item_id_by_name(itemName : String) -> String:
	for i in range(_allItems):
		if itemName == _allItems[i].get_name():
			return inventoryName + str(i)
			
	# if item name not found
	printerr("couldn't find item with name: " + itemName)
	return ""


func _update_weight():
	if has_node("background/weightLabel"):
		if $background/weightLabel != null:
			$background/weightLabel.text = str(_currentWeight) + " / " + str(maxWeight)


# when released, swap items
func _on_slot_released(index):
	if not get_parent().is_visible() or Global.paused:
		return
		
	_lastSelected = _selected
	_selected = index
	
	emit_signal("on_slot_toggled", false, _selected, inventoryName)
	

func _on_slot_pressed(index : String):
	if not get_parent().is_visible() or Global.paused:
		return
		
	_lastSelected = _selected
	_selected = index
	#print("selected: " + str(index))
	emit_signal("on_slot_toggled", true, _selected, inventoryName)
	
	if _get_selected_slot() == null:
		#itemList.unselect(_selected)
		_slots[str(_selected)].set_unselected()
		return
	_slots[_selected].set_selected()
	