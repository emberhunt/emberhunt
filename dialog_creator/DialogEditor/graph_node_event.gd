extends "res://DialogEditor/default_graph_node.gd"


var items = {}
var itemsAmount = {}

var _nextSuccess
var _nextFailure

var _currentSelected

func _ready():
	pass

func set_item_suggestions(key : String, suggestions : Array, additionalLineEdits = 0):
	items[key] = []
	itemsAmount[key] = additionalLineEdits
	$eventType.add_item(key)
	for i in range(suggestions.size()):
		items[key].append(suggestions[i])

func clear_item_suggestions(key):
	items.erase(key)
	for i in range($eventType.get_item_count()):
		if $eventType.get_item_text(i) == key:
			$eventType.remove_item(i)

func set_selected_item(type, args : Dictionary):
	var typeChild = get_node("eventType")
	
	_nextSuccess = args.next_success
	_nextFailure = args.next_failure
	
	# search type
	for i in range(typeChild.get_item_count()):
		if typeChild.get_item_text(i) == type:
			_on_eventType_item_selected(i)
			$eventType.select(i)
			
	for i in range(typeChild.get_item_count()):
		if typeChild.get_item_text(i) == args.event_params["0"]:
			typeChild.select(i)
	
	for i in range(args.event_params.size() - 1):
		var child = get_child(i+4)
		child.value = int(args.event_params[str(i+1)])
	

func _set_items(key):
	_currentSelected = key
	# delete existing items
	for it in range(get_child_count() - 3):
		var child = get_child(3)
		remove_child(child)
		child.queue_free()
	
	var options := OptionButton.new()
	for i in range(items[key].size()):
		options.add_item(items[key][i], i)
	
	add_child(options)
	
	for i in range(itemsAmount[key]):
		var amount := SpinBox.new()
		add_child(amount)

func get_event_param_amount():
	if _currentSelected == null:
		return ""
	return itemsAmount[_currentSelected] + 1


func get_event_param(index):
	var child = get_child(3 + index)
	print(child.get_class())
	if child.get_class() == "OptionButton":
		return child.get_item_text(child.selected)
	else:
		return child.value
		
func get_event_type():
	return $eventType.get_item_text($eventType.selected)

func _on_eventType_item_selected(id):
	if id == -1:
		return
	id -= 1
	_set_items(items.keys()[id])
	
func get_selected_key():
	return $eventType.get_item_text($eventType.selected)

func set_selected(key):
	_set_items(key)
