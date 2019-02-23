extends TouchScreenButton

var radius = 100
var origin
onready var player_node = get_node('../../../body')
onready var other_node = get_node("../shootButton")

var touch_power = 0
var touch_direction = 0
var touch_rotation = 0

var index

var disabled = false
var isPressed = false

func isInArea(pos):
	if pos.x<2*radius+50 and pos.y>get_viewport().size.y-(2*radius+50):
		return true
	else:
		return false

func _ready():
	# Adjust position on screen
	position.x = radius+30
	position.y = get_viewport().size.y-(radius+30)
	origin = position

func _input(event):
	if event is InputEventScreenTouch:
		if not event.pressed and event.index == index:
			isPressed = false
			$buttonSprite.global_position = origin
			$buttonSprite.hide()
			$background.hide()
			player_node.speed = 0
		if event.pressed and not isPressed and isInArea(event.position):
			index = event.index
			isPressed = true
			var localPos = event.position - origin
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
			
	if event is InputEventScreenDrag:
		if not disabled:
			if event.index == index:
				var localPos = event.position - origin
				if isPressed:
					index = event.index
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