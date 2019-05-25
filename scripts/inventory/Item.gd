extends TextureButton

var itemID = "woodsword"
var quantity = 0
var slotID = -1
var dragging = false
var clicked = false

onready var origin = rect_global_position
var mouse_origin = Vector2()

func _ready():
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
		print("INFO")

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