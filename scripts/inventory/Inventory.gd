"""
This is a inventory that only can be used
by including it in an inventory system

- use EITHER:
	1. Gridcontainer with colums and inventorySize export var
	2. OR custom container, where you have to instanciate the 
	   item slots yourself 
"""
#tool
extends Control

class_name Inventory

# signaled, when pressed or released
signal on_slot_toggled(is_pressed, _selected, inventoryName)

# types
const Item = preload("res://scripts/inventory/ItemStats.gd")
const Slot = preload("res://scripts/inventory/slot.gd")
const ItemSlot = preload("res://scripts/inventory/ItemSlot.gd")
const Character = preload("res://scripts/character.gd")

# vars
onready var itemSlots = $slots
onready var weightLabel = $weightLabel


# the name should be something like: "playerinventory", "chest" or "merchant"
export(String) var inventoryDisplayName = "inventory" setget update_inventory_name
export(int) var inventorySize = 0 setget update_inventory_size
export(int) var columns = 4 setget update_inventory_columns
export(bool) var weightEnabled = false setget update_weight_enabled
export(float) var maxWeight = -1 setget _update_max_weight

var _currentWeight = 0.0

var _slots = []

var _lastSelected = -1
var _selected = -1

func _ready():
	update_inventory_size(inventorySize)
	set_process_input(true)
	
	$nameBackground/name.set_text(inventoryDisplayName)
	
	if itemSlots is GridContainer:
		pass
#
	else:
		inventorySize = itemSlots.get_child_count()
		for i in range(inventorySize):
			itemSlots.get_child(i).init(i)
		add_existing_slots()
		
	
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


func can_add_item(item) -> bool:
	# search if same item exists and is stackable,
	# and if it is stackable, is it max stacked
	
	if weightEnabled:
		if item.get_weight() + _currentWeight > maxWeight:
			return false
	
	for i in range(_slots.size()):
		var currentSlot = get_slot(i)
		var curItem = get_slot(i)._item
		if currentSlot._item != null:
			if curItem.get_id() == item.get_id() and curItem.is_stackable():
				if currentSlot.get_amount() < curItem.get_stack_size():
					return true

	# if not stackable/not exist/full stack then add to new slot
	if _get_next_free_slot_id() == -1:
		return false
	
	return true


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
	var emptySlot = Slot.new(newSlotIndex)
#	if _slots.size() == 0:
#		emptySlot.add_slot_requirement(SlotRequirement.SlotRequirement.CLASS, \
#				Character.get_character_type_name(Character.CharacterType.KNIGHT))
#		emptySlot.set_slot_types([Item.get_type_name(Item.ItemType.GREAT_SWORD)])
	
	_slots.append(emptySlot)
	$slots.add_child(_slots[newSlotIndex]._slot)
	
	_slots[newSlotIndex]._slot.connect("on_slot_pressed", self, "_on_slot_pressed") 
	_slots[newSlotIndex]._slot.connect("on_slot_released", self, "_on_slot_released") 


func remove_last_slot():
	if not _slots.empty():
		remove_slot(_slots.size() - 1)

func remove_slot(slotId):
	if not (has_node("slots") and $slots != null):
		return 

	_slots.remove(slotId)
	get_child(slotId).queue_free()

func clear():
	for i in range(_slots.size()):
		_slots[i]._item = null
		_slots[i]._amount = 0

func remove_item(slotId : int, amount : int = 0) -> Item:
	var item = get_slot(slotId)._item
	if item == null:
		return null
	add_weight(-item.get_weight())
	get_slot(slotId).remove_item(amount)
	return item


# add item to inventory
#return false if couldn't add item to inv
func add_item(item : Item, amount : int = 1):
	# search if same item exists and is stackable,
	# and if it is stackable, is it max stacked
	
	if weightEnabled:
		if item.get_weight() + _currentWeight > maxWeight:
			return false
	
	for i in range(_slots.size()):
		var currentSlot = get_slot(i)
		var curItem = get_slot(i)._item
		if currentSlot._item != null:
			if curItem.get_id() == item.get_id() and curItem.is_stackable():
				if currentSlot.get_amount() < curItem.get_stack_size():
					#print("item id of stackable: " + str(currentSlot.get_amount()))
					currentSlot.set_amount(currentSlot.get_amount() + 1)
					if weightEnabled:
						_currentWeight += item.get_weight()
						_update_weight()
					return i

	# if not stackable/not exist/full stack then add to new slot
	var freeId = _get_next_free_slot_id()
	if freeId == -1:
		return -1

	_slots[freeId].set_item(item, amount)
	if weightEnabled:
		_currentWeight += item.get_weight()
		_update_weight()
	return freeId

func get_inventory_save_data() -> Dictionary:
	var data = {}
	data.inventorySize = _slots.size()
	data.columns = columns
	data.maxWeight = maxWeight
	data.weightEnabled = weightEnabled
	for i in range(_slots.size()):
		var slot = _slots[_slots.keys()[i]]
		
		var itemId = slot.get_item().get_item_id()
		var amount = slot.get_amount()
		
		data.slots[_slots.keys()[i]] = { "item_id" : itemId, "amount" : amount }
	
	return data

# slots max size
func load_inventory_from_data(inventorySize, columns, weightEnabled, data):
	update_inventory_size(inventorySize)
	update_inventory_columns(columns)
	update_weight_enabled(weightEnabled)
	
	for i in range(data.size()):
		var slot = data[data.keys()[i]]
		set_item(data.keys()[i], slot.item_id, slot.amount)

func set_item(id, item, amount = 1):
	_slots[id].set_item(get_item_by_id(item), amount)
	
	
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
	return Global.allItems[id]


func get_slot_size():
	return _slots.size() 


func get_slots() -> Array:
	return _slots
	
func get_item_at_slot(slotId : int) -> Item:
	return _slots[slotId]._item
	

func get_slot(pos : int):
	return _slots[pos]


func _get_next_free_slot_id():
	for i in range(inventorySize):
		if get_slot(i).get_item() == null:
			return i
	return -1
	
	
func get_selected_slot():
	return _slots[_selected]


func get_selected_item() -> Item:
	return _slots[_selected]._item
	
	
func get_last_selected_slot():
	return _slots[_lastSelected]
	

func get_slot_weight(id):
	return _slots[id].get_weight()
	
	
func get_last_selected_item() -> Item:
	return _slots[_lastSelected]._item
	
	
func get_id() -> String:
	return self.name
	
func get_display_name() -> String:
	return inventoryDisplayName


func get_item_id_by_name(itemName : String) -> String:
	for i in range(Global.allItems.values()):
		if itemName == Global.allItems.values()[i].get_name():
			return Global.allItems.values()[i]
			
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
	
	emit_signal("on_slot_toggled", false, _selected, self.name)
	

func _on_slot_pressed(index):
	if not is_visible() or Global.paused:
		return
		
	_lastSelected = _selected
	_selected = index
	emit_signal("on_slot_toggled", true, _selected, self.name)


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