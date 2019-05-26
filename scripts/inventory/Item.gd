extends TextureButton

var itemID = "woodsword"
var quantity = 0
var slotID = -1
var dragging = false
var clicked = false

var itemData = {}

onready var origin = rect_global_position
var mouse_origin = Vector2()

func _ready():
	# Read the item data
	itemData = Global.items[itemID]
	
	# Set the texture
	if itemID != "":
		texture_normal = Global.loaded_item_sprites[itemID]
	else:
		texture_normal = null
	$Quantity.set_text(str(quantity))

func _on_Item_button_down():
	origin = rect_global_position
	clicked = true
	mouse_origin = get_global_mouse_position()


func _on_Item_button_up():
	clicked = false
	if dragging:
		dragging = false
		# Iterate through all slots to see if the mouse is on any of them
		for slot in get_node("../../Container/ScrollContainer/GridContainer").get_children():
			# Check x and y coordinates
			var mousepos = slot.get_local_mouse_position()
			if mousepos.x <= 64  and mousepos.y <= 64:
				# Found the slot
				# Check if it's free
				var free = true
				var other_item
				for item in get_node("..").get_children():
					if item.slotID == int(slot.get_name()):
						free = false
						other_item = item
						break
				if not free:
					# Now just move the other item to the original item's position
					other_item.rect_global_position = origin
					other_item.slotID = slotID
				rect_global_position = slot.rect_global_position+Vector2(8,8)
				slotID = int(slot.get_name())
				# Inform the server about the changes
				# Generate an appropriate dict
				var newInv = {}
				for item in get_node("..").get_children():
					newInv[item.slotID] = {"item_id" : item.itemID, "quantity" : item.quantity}
				Networking.sendInventory(newInv)
				return
		rect_global_position = origin
	else:
		# Show info about item
		var info_window = preload("res://scenes/inventory/ItemInfo.tscn").instance()
		info_window.set_name("ItemInfo")
		info_window.positionWindowOnScreen(rect_global_position, get_viewport().size)
		info_window.rect_global_position = Vector2(0,0)
		# Each item type has different item infos
		var infoFormatter = {
			"drops_from" : PoolStringArray(itemData["drops_from"]).join(", "),
			"stat_restrictions" : dict_to_string(itemData['stat_restrictions']),
			"stat_effects" : dict_to_string(itemData['stat_effects']),
			"damage" : str(itemData['min_damage']) if itemData['min_damage']==itemData['max_damage'] else str(itemData['min_damage'])+"-"+str(itemData['max_damage']),
			"fire_rate" : str(itemData['min_fire_rate']) if itemData['min_fire_rate']==itemData['max_fire_rate'] else str(itemData['min_fire_rate'])+"-"+str(itemData['max_fire_rate']),
			"bullets" : str(itemData['min_bullets']) if itemData['min_bullets']==itemData['max_bullets'] else str(itemData['min_bullets'])+"-"+str(itemData['max_bullets']),
			"bullet_speed" : str(itemData['min_speed']) if itemData['min_speed']==itemData['max_speed'] else str(itemData['min_speed'])+"-"+str(itemData['max_speed']),
			"bullet_range" : str(itemData['min_range']) if itemData['min_range']==itemData['max_range'] else str(itemData['min_range'])+"-"+str(itemData['max_range']),
			"bullet_spread" : str(itemData['bullet_spread']) if itemData['bullet_spread_random']==0 else str(itemData['bullet_spread']*(1-itemData['bullet_spread_random']))+"-"+str(itemData['bullet_spread']*(1+itemData['bullet_spread_random'])),
			"bullet_scale" : str(itemData['min_scale']) if itemData['min_scale']==itemData['max_scale'] else str(itemData['min_scale'])+"-"+str(itemData['max_scale']),
			"bullet_knockback" : str(itemData['min_knockback']) if itemData['min_knockback']==itemData['max_knockback'] else str(itemData['min_knockback'])+"-"+str(itemData['max_knockback']),
			"bullet_pierces" : "No" if itemData['max_pierces'] <= 0 else "Yes, "+str(itemData['min_pierces']) if itemData['min_pierces']==itemData['max_pierces'] else "Yes, "+str(itemData['min_pierces'])+"-"+str(itemData['max_pierces']),
			"heavy_attack" : "Yes" if itemData['heavy_attack'] else "No"
		}
		var infoLeft = Global.item_types[itemData.type].infoLeft.format(infoFormatter)
		var infoRight = Global.item_types[itemData.type].infoRight.format(infoFormatter)
		
		info_window.get_node("Background/Control/ItemTitle").set_text(itemData.title)
		info_window.get_node("Background/Control/ItemDescription").set_text(itemData.description)
		info_window.get_node("Background/Control/ItemType").set_text(itemData.type)
		info_window.get_node("Background/Control/ItemInfoLeft").set_text(infoLeft)
		info_window.get_node("Background/Control/ItemInfoRight").set_text(infoRight)
		info_window.get_node("Background/Control/ItemRarity").set_text("Rarity: "+str(itemData.rarity))
		get_node("../../..").add_child(info_window)

func dict_to_string(dict):
	if dict.size() == 0:
		return "None"
	var string = ""
	for key in dict.keys():
		string += "+"+str(dict[key])+" "+str(key)+", " if dict[key] > 0 else str(dict[key])+" "+str(key)+", "
	
	return string.rstrip(", ")

func _process(delta):
	if clicked and not dragging:
		# Check if we need to start dragging
		if (mouse_origin-get_global_mouse_position()).length() > 20:
			dragging = true
			rect_global_position = get_global_mouse_position()-Vector2(24,24)
			# Make it appear on top of other items
			get_node("..").move_child(self,get_node("..").get_child_count())
	if dragging:
		rect_global_position = get_global_mouse_position()-Vector2(24,24)