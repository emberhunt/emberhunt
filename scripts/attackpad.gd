extends Position2D

# Node setup:
# player node
# 	UI (CanvasLayer)
#		touchpad (Position2D) <- this script
#
# Make sure to either set a background texture 
# to auto-detect a drag radius or define a 
# maximum drag yourself.

export(Texture) var background_sprite = null # background texture for the touchpad, also used to auto-detect drag radius if no custom value is defined.
export(Texture) var foreground_sprite = null # dragable foreground texture for the touchpad
export(bool) var always_output_max_drag = false # always output the maximum drag value
export(int,-1,10000) var MAX_DRAG = -1 # maximum drag radius from touchpad's center in pixels
export(bool) var is_fixed = true # touchpad will only appear at the screen-local coordinates defined as fixed_position
export(Vector2) var fixed_position = Vector2(150,450) # if is_fixed is true, only appear if the user clicks inside the maximum_drag radius around fixed_poistion

onready var weapon_node = get_node("/root/player/body/weapon") # set to relativ path to the player

func _ready():
	fixed_position.y = get_viewport().get_size().y-170
	fixed_position.x = get_viewport().get_size().x-170
	if background_sprite != null:
		$background.texture = background_sprite
	if foreground_sprite != null:
		$background/foreground.texture = foreground_sprite
		
	if MAX_DRAG == -1: # MAX_DRAG -1 means the texture size will be used to define maximum drag radius
		if $background.get_texture() != null:
			MAX_DRAG = $background.get_texture().get_size().x/2
		else: # if neither MAX_DRAG nor a background texture defined, throw an error
			var hacky_error
			hacky_error.EASY_TOUCHPAD_no_max_drag_or_background_texture_defined()

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed: # left mouse button
			if is_fixed: # touchpad got a fix position
				if (get_global_mouse_position()-fixed_position).length() <= MAX_DRAG:
					position = fixed_position
					$background.show() # show touchpad on click
			else: # touchpad can be used anywhere on the screen
				position = get_global_mouse_position()
				$background.show() # show touchpad on click
		elif not event.pressed: # left mouse released
			$background.hide() # hide touchpad
	
	if $background.visible == true: # if touchpad is in use right now
		if get_local_mouse_position().length() <= MAX_DRAG:
			$background/foreground.position = get_local_mouse_position() # move touchpad's foreground texture according to the drag
		else:
			$background/foreground.position = get_local_mouse_position().normalized()*MAX_DRAG # cap touchpad's foreground texture drag radius
		
		var touchpad_rotation = atan2(get_local_mouse_position().x,get_local_mouse_position().y*-1) # depending on your sprites base rotation you may want to invert x or y or both (*-1)
		var touchpad_direction = get_local_mouse_position().normalized()
		var touchpad_power = get_local_mouse_position().length()
		if touchpad_power > MAX_DRAG or always_output_max_drag: # cap maximum touchpad_power output at maximum drag radius
			touchpad_power = MAX_DRAG


		# ******************************************************************************************* #
		# Change the following lines according to the class variables / functions of your player node #
		# ******************************************************************************************* #
		# we dont need rotation do we?
		# we do for the weapon sprite
		weapon_node.rotation = touchpad_rotation# float - rotation in rad
#		weapon_node.direction = touchpad_direction # Vector2() - normalized direction vector
		weapon_node.attacking = true
	else:
		weapon_node.attacking = false #Sets attacking state to false