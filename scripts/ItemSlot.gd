extends TextureButton

signal on_slot_released(id)
signal on_slot_pressed(id)

const _backgroundTexture = preload("res://assets/inventory/slotBackground.png")
const _backgroundTextureSelected = preload("res://assets/inventory/slotBackground_selected.png")

# how many items has the stack
onready var _labelAmount = $label
onready var _itemTexture = $itemTexture

var _texture : Texture = null

var _id : String = ""


#custom init function
func init(id):
	_id = id
	
func _ready():
	set_process_input(true)
	

func _input(event):
	if event is InputEventMouseButton:
#		if is_position_in_description_range(event.position):
#			print("in range")
		if _is_position_on_slot(event.position):
			if event.button_index == BUTTON_LEFT:
				if not event.pressed:
					emit_signal("on_slot_released", _id)
				else:
					emit_signal("on_slot_pressed", _id)
		

			
func _is_position_on_slot(position) -> bool: # get_viewport().get_mouse_position()
	if position.x > rect_global_position.x and \
		 position.y > rect_global_position.y and \
		 position.x < rect_global_position.x + rect_size.x and \
		 position.y < rect_global_position.y + rect_size.y:
		return true
	else:
		return false


func get_id() -> String:
	return _id
	

func set_item_texture(texture : Texture):
	_itemTexture.texture = texture
	

func get_amount() -> int:
	if _labelAmount.text == "":
		return -1
	else:
		return int(_labelAmount.text)
		

# only show item number if > 1
func set_amount(amount : int):
	if amount >= 2:
		_labelAmount.visible = true
	else:
		_labelAmount.visible = false
	
	_labelAmount.text = str(amount)
	
	
func set_selected():
	texture_normal = _backgroundTextureSelected
	

func set_unselected():
	texture_normal = _backgroundTexture
