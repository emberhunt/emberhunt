extends TouchScreenButton

var radius = 100
var origin
onready var weapon_node = get_parent().get_parent().get_node('body/weapon')

var touch_power = 0
var touch_direction = 0
var touch_rotation = 0

var index

var disabled = false

func _ready():
	# Adjust position on screen
	position.x = get_viewport().size.x-(radius+30)
	position.y = get_viewport().size.y-(radius+30)
	origin = position

func _input(event):
	if event is InputEventScreenTouch:
		if not event.pressed and is_pressed() and index == event.index:
			$buttonSprite.global_position = origin
			$buttonSprite.hide()
			$background.hide()
			weapon_node.attacking = false
			
	if event is InputEventScreenDrag:
		if not disabled:
			if event.position.x > OS.get_screen_size().x/2 - 200:
				var localPos = event.position - origin
				if is_pressed():
					index = event.index
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