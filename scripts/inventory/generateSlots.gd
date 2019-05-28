extends GridContainer

onready var stats = Global.charactersData[Global.charID]

var special_slots = 4

func _ready():
	# Generate columns for gridContainer
	columns = int((get_viewport().size.x-110)/66.0)-1
	# Generate slots
	for slot in range(stats.level+20-special_slots):
		var scene = preload("res://scenes/inventory/InventorySlot.tscn")
		var scene_instance = scene.instance()
		scene_instance.set_name(str(slot+special_slots))
		add_child(scene_instance)
	# Add items to slots
	var items = stats['inventory']
	for item in items.keys():
		var scene_instance = preload("res://scenes/inventory/Item.tscn").instance()
		if int(item) <= 3:
			scene_instance.rect_global_position = get_node("../../"+item).rect_global_position+Vector2(8,8)
		else:
			scene_instance.rect_global_position = rect_global_position+Vector2(((int(item)-special_slots)%columns)*66+8,int((int(item)-special_slots)/columns)*66+8)
		scene_instance.itemID = items[item]["item_id"]
		scene_instance.quantity = items[item]["quantity"]
		scene_instance.slotID = int(item)
		get_node("../../../Items").add_child(scene_instance)