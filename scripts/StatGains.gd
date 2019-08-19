extends Control

var _gains = {"failed to load gains": 0}

var time_passed = 0.0

var last_stat = 0

func init(gains):
	_gains = gains

func _ready():
	get_child(0).set_text( "+"+str(_gains.values()[0])+" "+_gains.keys()[0].capitalize().to_upper() )

func _process(delta):
	time_passed+=delta
	
	if fmod(time_passed, 3.0) < 0.5:
		# First increase alpha
		get_child(0).modulate = Color(1, 1, 1, fmod(time_passed, 3.0)*2)
	elif fmod(time_passed, 3.0) > 2.5:
		# Then decrease alpha
		get_child(0).modulate = Color(1, 1, 1, 1-(fmod(time_passed, 3.0)-2.5)*2)
	
	# Text
	if last_stat != floor(time_passed/3.0):
		if floor(time_passed/3.0) > _gains.size()-1:
			queue_free()
		else:
			get_child(0).set_text( "+"+str(_gains.values()[floor(time_passed/3.0)])+" "+_gains.keys()[floor(time_passed/3.0)].capitalize().to_upper() )
			last_stat = floor(time_passed/3.0)