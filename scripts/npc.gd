extends Node2D


signal on_sight_entered
signal on_interaction_range_entered
signal on_interaction_range_exited

export(String) var npcName
export(String) var conversationName

func _ready():
	pass


func _on_interactionRange_body_entered(body):
	emit_signal("on_interaction_range_entered", self)


func _on_sightRange_body_entered(body):
	emit_signal("on_sight_entered", self)


func _on_interactionRange_body_exited(body):
	emit_signal("on_interaction_range_exited", self)
