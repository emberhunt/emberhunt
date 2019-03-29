extends Node2D

func _ready():
	for i in range($npcs.get_child_count()):
		$npcs.get_child(i).connect("on_interaction_range_entered", self, "interation_range_entered")
		$npcs.get_child(i).connect("on_sight_entered", self, "sight_range_entered")



func _process(delta):
	$sprite.position = get_global_mouse_position()


func interation_range_entered(npc):
	print("interact")
	$dialogSystem.start_conversation("Gertrud")


func sight_range_entered(npc):
	print("sight")
	pass

