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
			"damage" : str(itemData['damage']) if str(itemData['damage_extra_random'])==str([0,0]) else str(itemData['damage']+itemData['damage_extra_random'][0])+"-"+str(itemData['damage']+itemData['damage_extra_random'][1]),
			"fire_rate" : str(itemData['fire_rate']) if itemData['fire_rate_random']==0 else str(itemData['fire_rate']*(1-itemData['fire_rate_random']))+"-"+str(itemData['fire_rate']*(1+itemData['fire_rate_random'])),
			"bullets" : str(itemData['bullets']) if str(itemData['bullets_random'])==str([0,0]) else str(itemData['bullets']+itemData['bullets_random'][0])+"-"+str(itemData['bullets']+itemData['bullets_random'][1]),
			"bullet_speed" : str(itemData['bullet_speed']) if itemData['bullet_speed_random']==0 else str(itemData['bullet_speed']*(1-itemData['bullet_speed_random']))+"-"+str(itemData['bullet_speed']*(1+itemData['bullet_speed_random'])),
			"bullet_range" : str(itemData['bullet_range']) if itemData['bullet_range_random']==0 else str(itemData['bullet_range']*(1-itemData['bullet_range_random']))+"-"+str(itemData['bullet_range']*(1+itemData['bullet_range_random'])),
			"bullet_spread" : str(itemData['bullet_spread']) if itemData['bullet_spread_random']==0 else str(itemData['bullet_spread']*(1-itemData['bullet_spread_random']))+"-"+str(itemData['bullet_spread']*(1+itemData['bullet_spread_random'])),
			"bullet_scale" : str(itemData['bullet_scale']) if itemData['bullet_scale_random']==0 else str(itemData['bullet_scale']*(1-itemData['bullet_scale_random']))+"-"+str(itemData['bullet_scale']*(1+itemData['bullet_scale_random'])),
			"bullet_knockback" : str(itemData['bullet_knockback']) if itemData['bullet_knockback_random']==0 else str(itemData['bullet_knockback']*(1-itemData['bullet_knockback_random']))+"-"+str(itemData['bullet_knockback']*(1+itemData['bullet_knockback_random'])),
			"bullet_pierce" : str(itemData['bullet_pierce']) if str(itemData['bullet_pierce_random'])==str([0,0]) else str(itemData['bullet_pierce']+itemData['bullet_pierce_random'][0])+"-"+str(itemData['bullet_pierce']+itemData['bullet_pierce_random'][1]),
			"heavy_attack" : "yes" if itemData['heavy_attack'] else "no"
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