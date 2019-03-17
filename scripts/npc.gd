extends Node2D


signal on_sight_entered
signal on_interaction_range_entered


func _ready():
	pass


func _on_interactionRange_body_entered(body):
	emit_signal("on_interaction_range_entered", self)


func _on_sightRange_body_entered(body):
	emit_signal("on_sight_entered", self)
