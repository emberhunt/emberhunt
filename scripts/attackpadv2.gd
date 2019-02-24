extends TouchScreenButton

var radius = 100
var origin
onready var _weaponNode = null#get_parent().get_parent().get_node('body/weapon')

var touchPower = 0
var touchDirection = 0
var touchRotation = 0

var index

var disabled = false
var isPressed = false

func isInArea(pos):
	if pos.x > get_viewport().size.x-(2*radius+50) and pos.y>get_viewport().size.y-(2*radius+50):
		return true
	else:
		return false

func init(weaponNode : Node2D):
	if weaponNode == null:
		print("no weapon")
		return
	_weaponNode = weaponNode


func _ready():
	# Adjust position on screen
	position.x = get_viewport().size.x-(radius+30)
	position.y = get_viewport().size.y-(radius+30)
	origin = position


func _input(event):
	if _weaponNode == null:
		print("no body")
		return
	
	if event is InputEventScreenTouch:
		if not event.pressed and index == event.index:
			isPressed = false
			$buttonSprite.global_position = origin
			$buttonSprite.hide()
			$background.hide()
			_weaponNode.attacking = false
		if event.pressed and not isPressed and isInArea(event.position):
			if not disabled:
				index = event.index
				isPressed = true
				var localPos = event.position - origin
				$buttonSprite.show()
				$background.show()
				$buttonSprite.global_position = event.position
				touchPower = localPos.length()
				touchDirection = localPos.normalized()
				touchRotation = atan2(localPos.x, localPos.y*-1)
				if touchPower > radius:
					touchPower = radius
					$buttonSprite.global_position = radius*touchDirection + origin
				_weaponNode.rotation = touchRotation
				_weaponNode.attacking = true
			
	if event is InputEventScreenDrag:
		if not disabled:
			if event.index == index:
				var localPos = event.position - origin
				if isPressed:
					index = event.index
					$buttonSprite.show()
					$background.show()
					$buttonSprite.global_position = event.position
					touchPower = localPos.length()
					touchDirection = localPos.normalized()
					touchRotation = atan2(localPos.x, localPos.y*-1)
					if touchPower > radius:
						touchPower = radius
						$buttonSprite.global_position = radius*touchDirection + origin
					_weaponNode.rotation = touchRotation
					_weaponNode.attacking = true