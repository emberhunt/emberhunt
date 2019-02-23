extends TouchScreenButton

var radius = 100
var origin
var _playerBody : KinematicBody2D = null#get_parent().get_parent().get_node('body')

var touchPower = 0
var touchDirection = 0
var touchRotation = 0

var index

var disabled = false

func init(playerBody : KinematicBody2D):
	_playerBody = playerBody


func _ready():
	# Adjust position on screen
	position.x = radius+30
	position.y = get_viewport().size.y-(radius+30)
	origin = position


func _input(event):
	if _playerBody == null:
		return
	
	if event is InputEventScreenTouch:
		if not event.pressed and is_pressed() and event.index == index:
			$buttonSprite.global_position = origin
			$buttonSprite.hide()
			$background.hide()
			_playerBody.speed = 0
			
	if event is InputEventScreenDrag:
		if not disabled:
			if event.position.x < OS.get_screen_size().x/2 - 150:
				var localPos = event.position - origin
				if is_pressed():
					index = event.index
					$buttonSprite.show()
					$background.show()
					$buttonSprite.global_position = event.position
					touchPower = localPos.length()
					touchDirection = localPos.normalized()
					if touchPower > radius:
						touchPower = radius
						$buttonSprite.global_position = radius*touchDirection + origin
					_playerBody.speed = touchPower
					_playerBody.direction = touchDirection