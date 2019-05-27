extends Node2D

var gravity = Vector2(0, 100)
var velocity = Vector2(0, -20)
var ttk = .5
# Called when the node enters the scene tree for the first time.
func _ready():
	# range of randoms between 10 - 20 and -10 - -20
	var rand = randi()%10 + 10
	var neg = randi()%2
	if neg == 0:
		rand = -rand
	velocity.x = rand
	pass

func _process(delta):
	ttk -= delta
	if ttk <= 0:
		queue_free()
	velocity += gravity * delta
	position = position + velocity*delta
	pass
