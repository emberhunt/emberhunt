extends TouchScreenButton

const radius = 150
onready var origin = global_position
onready var player_node = get_parent().get_parent().get_node('body')
onready var other_node = get_parent().get_node("shootButton")

var touch_power = 0
var touch_direction = 0
var touch_rotation = 0

func _input(event):
	if event is InputEventScreenTouch:
		if not event.pressed and is_pressed():
			$buttonSprite.global_position = origin
			$buttonSprite.hide()
			$background.hide()
			player_node.speed = 0
			
	if event is InputEventScreenDrag:
		if event.position.x < OS.get_screen_size().x/2 - 150:
			var localPos = event.position - origin
			if is_pressed():
				$buttonSprite.show()
				$background.show()
				$buttonSprite.global_position = event.position
				touch_power = localPos.length()
				touch_direction = localPos.normalized()
				if touch_power > radius:
					touch_power = radius
					$buttonSprite.global_position = radius*touch_direction + origin
				player_node.speed = touch_power
				player_node.direction = touch_direction