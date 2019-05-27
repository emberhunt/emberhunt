extends Node


# Default settings
var boolSound = true
var Sound = 1
var boolMusic = true
var Music = 1
var quality = "High" # High, Medium, Low
var touchpadPosition = "Fixed"
var showDamageNumbers = true
var UUID = false

var nickname = "Offline"

var charactersData = {}

var charID = 0

var worldReadyFunctions = {}

var loaded_bullets = {}
var loaded_item_sprites = {}

var init_stats = {}
var items = {}
var item_types = {}

# game paused
var paused = false

func saveGame():
	var file = ConfigFile.new()
	file.load("user://emberhunt.save")
	file.set_value("Settings","boolSound",boolSound)
	file.set_value("Settings","Sound",Sound)
	file.set_value("Settings","boolMusic",boolMusic)
	file.set_value("Settings","Music",Music)
	file.set_value("Settings","quality",quality)
	file.set_value("Settings","touchpadPosition",touchpadPosition)
	file.set_value("Settings","showDamageNumbers",showDamageNumbers)
	file.set_value("Networking","uuid",UUID)
	file.save("user://emberhunt.save")

func loadGame():
	var file = ConfigFile.new()
	file.load("user://emberhunt.save")
	boolSound = file.get_value("Settings","boolSound", true)
	Sound = file.get_value("Settings","Sound", 1)
	boolMusic = file.get_value("Settings","boolMusic", true)
	Music = file.get_value("Settings","Music", 1)
	quality = file.get_value("Settings","quality", "High")
	touchpadPosition = file.get_value("Settings","touchpadPosition", "Fixed")
	showDamageNumbers = file.get_value("Settings","showDamageNumbers", true)
	UUID = file.get_value("Networking","uuid", false)

func _ready():
	loadGame()
	_load_bullets()
	_load_item_sprites()
	
	init_stats = load_json_from_file("res://data/class_init_stats.json")
	items = load_json_from_file("res://data/items.json")
	item_types = load_json_from_file("res://data/item_types.json")

func load_json_from_file(file_path):
	var file = File.new()
	file.open(file_path, file.READ)
	var text = file.get_as_text()
	file.close()
	return JSON.parse(text).result

func spawnPlayerAndGUI(world_name):
	# Add the player to the world
	var scene = load("res://scenes/player.tscn")
	var scene_instance = scene.instance()
	scene_instance.set_name("player")
	scene_instance.add_to_group("player")
	get_node("/root/"+world_name+"/Entities").add_child(scene_instance)
	# Add the GUI
	scene_instance = load("res://scenes/GUI.tscn").instance()
	scene_instance.set_name("GUI")
	get_node("/root/"+world_name).add_child(scene_instance)
	# Add YSort nodes
	var node = YSort.new()
	node.set_name("players")
	get_node("/root/"+world_name+"/Entities").add_child(node)
	node = YSort.new()
	node.set_name("projectiles")
	get_node("/root/"+world_name+"/Entities").add_child(node)
	node = YSort.new()
	node.set_name("items")
	get_node("/root/"+world_name+"/Entities").add_child(node)
	node = YSort.new()
	node.set_name("npc")
	get_node("/root/"+world_name+"/Entities").add_child(node)
	

func WorldReady(world_name):
	if worldReadyFunctions.has(world_name):
		worldReadyFunctions[world_name].call_func(world_name)

func _load_bullets():
	var directory = Directory.new()
	if directory.open("res://scenes/bullets/") == OK:
		directory.list_dir_begin()
		var file_name = directory.get_next()
		while( file_name != ""):
			if file_name.ends_with(".tscn"):
				loaded_bullets[file_name.trim_suffix(".tscn")] = load("res://scenes/bullets/"+file_name)
			file_name = directory.get_next()
	else:
		print("Error opening res://scenes/bullets/")
		
func _load_item_sprites():
	var directory = Directory.new()
	if directory.open("res://assets/inventory/items/") == OK:
		directory.list_dir_begin()
		var file_name = directory.get_next()
		while( file_name != ""):
			# Godot is weird
			if file_name.ends_with(".png.import"):
				loaded_item_sprites[file_name.trim_suffix(".png.import")] = load("res://assets/inventory/items/"+file_name.replace(".import",""))
			file_name = directory.get_next()
	else:
		print("Error opening res://assets/inventory/items/")