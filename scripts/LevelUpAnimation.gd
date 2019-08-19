extends Sprite

func _ready():
	get_node("AnimationPlayer").play("levelup")

func kill_myself():
	get_node("../Sprite").material = null
	queue_free()

func set_parent_whiteness(whiteness):
	if get_node("../Sprite").material == null:
		get_node("../Sprite").material = preload("res://shaders/white.tres")
	get_node("../Sprite").material.set_shader_param("strength",whiteness)