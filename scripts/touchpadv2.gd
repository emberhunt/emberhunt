extends TouchScreenButton

var radius = Global.touchpadRadius
var origin
onready var player_node = get_parent().get_parent().get_node('body')
onready var other_node = get_parent().get_node("shootButton")

var touch_power = 0
var touch_direction = 0
var touch_rotation = 0

var index

var disabled = false

func _ready():
	# Adjust position on screen
	position.x = radius+30
	position.y = get_viewport().size.y-(radius+30)
	origin = position

func _input(event):
	if event is InputEventScreenTouch:
		if not event.pressed and is_pressed() and event.index == index:
			$buttonSprite.global_position = origin
			$buttonSprite.hide()
			$background.hide()
			player_node.speed = 0
			
	if event is InputEventScreenDrag:
		if not disabled:
			if event.position.x < OS.get_screen_size().x/2 - 150:
				var localPos = event.position - origin
				if is_pressed():
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