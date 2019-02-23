extends TextureButton

signal on_slot_released(id)
signal on_slot_pressed(id)

const _backgroundTexture = preload("res://assets/inventory/slotBackground.png")
const _backgroundTextureSelected = preload("res://assets/inventory/slotBackground_selected.png")

# how many items has the stack
onready var _labelAmount = $Label
onready var _itemTexture = $ItemTexture

var _texture : Texture = null

var _id : String = ""
var _typeRequirements = {}

#custom init function
func init(id):
	_id = id
	
func _ready():
	set_process_input(true)
	pass
	

func _input(event):
	if event is InputEventMouseButton:
		if event.position.x > rect_global_position.x and \
		 event.position.y > rect_global_position.y and \
		 event.position.x < rect_global_position.x + rect_size.x and \
		 event.position.y < rect_global_position.y + rect_size.y:
			if event.button_index == BUTTON_LEFT:
				if not event.pressed:
					emit_signal("on_slot_released", _id)
				else:
					emit_signal("on_slot_pressed", _id)
		

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

