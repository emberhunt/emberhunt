extends Sprite

class_name ItemDrop


signal on_pickup_range_entered(child, item, amount)


export(int) var _itemId = -1
export(int) var _amount = 0


func _ready():
	pass

func _on_Area2D_body_entered(body):
	emit_signal("on_pickup_range_entered", self, _itemId, _amount)


