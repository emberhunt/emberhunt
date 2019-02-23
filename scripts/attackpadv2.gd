extends TouchScreenButton

var radius = 100
var origin
onready var _weaponNode = null#get_parent().get_parent().get_node('body/weapon')

var touchPower = 0
var touchDirection = 0
var touchRotation = 0

var index

var disabled = false

func init(weaponNode : Node2D):
	_weaponNode = weaponNode


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
			_weaponNode.attacking = false
			
	if event is InputEventScreenDrag:
		if not disabled:
			if event.position.x > OS.get_screen_size().x/2 - 200:
				var localPos = event.position - origin
				if is_pressed():
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