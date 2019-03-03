extends VBoxContainer

# False if nothing selected, Int if selected
var selected = false


func _ready():
	# Check if there are any characters
	if Global.charactersData.size() == 0:
		var node = Label.new()
		node.set_name("noCharactersYet")
		node.set_text("It looks like you don't have any characters yet.")
		add_child(node)
		move_child(node, 0)
	# Generate List Items based on character data
	for i in range(Global.charactersData.size()):
		var scene = preload("res://scenes/CharacterSelectionListItem.tscn")
		var scene_instance = scene.instance()
		scene_instance.set_name("Char"+str(i))
		scene_instance.get_node("Name").set_text(Global.charactersData[i]["name"])
		scene_instance.get_node("Class").set_text(Global.charactersData[i]["class"])
		scene_instance.get_node("Level").set_text(str(Global.charactersData[i]["level"])+"LvL")
		add_child(scene_instance)
		move_child(scene_instance, 0)
