extends TouchScreenButton

const radius = 150
var origin
onready var weapon_node = get_parent().get_parent().get_node('body/weapon')

var touch_power = 0
var touch_direction = 0
var touch_rotation = 0

func _ready():
	# Adjust position on screen
	position.x = get_viewport().size.x-200
	position.y = get_viewport().size.y-200
	origin = position

func _input(event):
	if event is InputEventScreenTouch:
		if not event.pressed and is_pressed():
			$buttonSprite.global_position = origin
			$buttonSprite.hide()
			$background.hide()
			weapon_node.attacking = false
			
	if event is InputEventScreenDrag:
		if event.position.x > OS.get_screen_size().x/2 - 200:
			var localPos = event.position - origin
			if is_pressed():
				$buttonSprite.show()
				$background.show()
				$buttonSprite.global_position = event.position
				touch_power = localPos.length()
				touch_direction = localPos.normalized()
				touch_rotation = atan2(localPos.x, localPos.y*-1)
				if touch_power > radius:
					touch_power = radius
					$buttonSprite.global_position = radius*touch_direction + origin
				weapon_node.rotation = touch_rotation
				weapon_node.attacking = true