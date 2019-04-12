extends Sprite
#tool
class_name ItemDrop

export(Texture) var _texture = preload("res://assets/inventory/items.png") setget update_texture

signal on_pickup_range_entered(child, item, amount)
signal on_pickup_range_exited(child, item, amount)


export(int) var _itemId = -1 setget update_item_id
export(int) var _amount = 1
export(bool) var _autoSelectRegion = true

var _itemTextureSize = 16

func _ready():
	pass

func _on_Area2D_body_entered(body):
	emit_signal("on_pickup_range_entered", self, _itemId, _amount)

func _on_area_body_exited(body):
	emit_signal("on_pickup_range_exited", self, _itemId, _amount)

func update_item_id(itemId):
	_itemId = itemId
	if _autoSelectRegion:
		set_region_rect(Rect2(\
				(_itemId * _itemTextureSize) % int(_texture.get_size().x), \
				_itemId / int(_texture.get_size().x / _itemTextureSize) * _itemTextureSize, \
				_itemTextureSize, _itemTextureSize))

func update_texture(texture):
	_texture = texture
	set_texture(_texture)