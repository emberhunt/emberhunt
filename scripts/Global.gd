extends Node


# Default settings
var boolSound = true
var Sound = 1
var boolMusic = true
var Music = 1
var quality = "High" # High, Medium, Low
var touchpadPosition = "Fixed"
var UUID = false

const itemAtlas = preload("res://assets/inventory/items.png")

var nickname = "Offline"

var charactersData = {}

var charID = 0

var worldReadyFunctions = {}

var playerPath = ""
var guiPath = ""

const init_stats = {
	"Knight" : {
		"max_hp" : 160,
		"max_mp" : 120,
		"strength" : 8,
		"agility" : 4,
		"magic" : 3,
		"luck" : 1,
		"physical_defense" : 18,
		"magic_defense" : 11 
	},
	"Berserker" : {
		"max_hp" : 120,
		"max_mp" : 115,
		"strength" : 15,
		"agility" : 11,
		"magic" : 4,
		"luck" : 1,
		"physical_defense" : 12,
		"magic_defense" : 7
	},
	"Assassin" : {
		"max_hp" : 100,
		"max_mp" : 100,
		"strength" : 6,
		"agility" : 14,
		"magic" : 4,
		"luck" : 1,
		"physical_defense" : 7,
		"magic_defense" : 7 
	},
	"Sniper" : {
		"max_hp" : 80,
		"max_mp" : 125,
		"strength" : 9,
		"agility" : 8,
		"magic" : 6,
		"luck" : 1,
		"physical_defense" : 6,
		"magic_defense" : 6 
	},
	"Hunter" : {
		"max_hp" : 90,
		"max_mp" : 115,
		"strength" : 6,
		"agility" : 8,
		"magic" : 5,
		"luck" : 1,
		"physical_defense" : 6,
		"magic_defense" : 6 
	},
	"Arsonist" : {
		"max_hp" : 70,
		"max_mp" : 200,
		"strength" : 3,
		"agility" : 9,
		"magic" : 13,
		"luck" : 1,
		"physical_defense" : 4,
		"magic_defense" : 16 
	},
	"Brand" : {
		"max_hp" : 70,
		"max_mp" : 180,
		"strength" : 4,
		"agility" : 7,
		"magic" : 8,
		"luck" : 1,
		"physical_defense" : 4,
		"magic_defense" : 15 
	},
	"Herald" : {
		"max_hp" : 110,
		"max_mp" : 240,
		"strength" : 3,
		"agility" : 10,
		"magic" : 9,
		"luck" : 1,
		"physical_defense" : 5,
		"magic_defense" : 19 
	},
	"Redeemer" : {
		"max_hp" : 65,
		"max_mp" : 165,
		"strength" : 2,
		"agility" : 10,
		"magic" : 9,
		"luck" : 1,
		"physical_defense" : 5,
		"magic_defense" : 18 
	},
	"Druid" : {
		"max_hp" : 65,
		"max_mp" : 170,
		"strength" : 4,
		"agility" : 12,
		"magic" : 11,
		"luck" : 1,
		"physical_defense" : 4,
		"magic_defense" : 18 
	}
}


# data of all items loaded once
var allItems = {}
var allDialogs = {}
var playerInventory = {}
var playerEquipment = {}

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
	UUID = file.get_value("Networking","uuid", false)

func loadItems():
	var file = File.new()
	file.open("res://assets/inventory/all_items.json", file.READ)
	var dataText = file.get_as_text()
	file.close()
	var data = JSON.parse(dataText)
	
	if data.error != OK:
		DebugConsole.error("cou	ldn't load items!")
		return
	else:
		DebugConsole.warn("loading items was successful!")
		
		#print("Problems loading " + fileName + " (in Inventory.gd)")
	
	data = data.result
	for i in range(data.size()):
		var itemData = data[str(i)]
		allItems[i] = Item.new(
				i,
				itemData["name"],
				Item.get_type_from_name(itemData["type"]),
				itemData["weight"],
				itemData["value"],
				itemData["effects"],
				itemData["requirements"],
				itemData["stats"],
				itemData["description"],
				itemData["texture_path"],
				itemData["texture_region"],
				itemData["slots_use"],
				itemData["stack_size"],
				itemData["stackable"],
				itemData["usable"],
				itemData["discardable"],
				itemData["sellable"],
				itemData["consumable"]
				)
				
func load_dialogs():
	var file = File.new()
	file.open("res://assets/dialogs/dialogs.json", file.READ)
	var dataText = file.get_as_text()
	file.close()
	var data = JSON.parse(dataText)
	
	if data.error != OK:
		DebugConsole.error("couldn't load dialogs!")
		return
	else:
		DebugConsole.warn("loading dialogs was successful!")
	
	data = data.result
	for i in range(data.size()):
		var conversation = data[data.keys()[i]]
		allDialogs[data.keys()[i]] = conversation

func load_inventory():
	var file = File.new()
	file.open("res://assets/inventory/inventories.json", file.READ)
	var data = JSON.parse(file.get_as_text())

	if data.error != OK:
		DebugConsole.error("couldn't load inventory!")
		return
	else:
		DebugConsole.warn("loading inventory was successful!")

	data = data.result
	for i in range(data.size()):
		var conversation = data[data.keys()[i]]
		allDialogs[data.keys()[i]] = conversation

func _ready():
	loadItems()
	load_dialogs()
	loadGame()

func spawnPlayerAndGUI(world_name):
	# Add the player to the world
	var scene = load("res://scenes/player.tscn")
	var scene_instance = scene.instance()
	scene_instance.set_name("player")
	scene_instance.add_to_group("player")
	get_node("/root/"+world_name+"/YSort").add_child(scene_instance)
	# Add the GUI
	scene_instance = load("res://scenes/GUI.tscn").instance()
	scene_instance.set_name("GUI")
	get_node("/root/"+world_name).add_child(scene_instance)

func WorldReady(world_name):
	if worldReadyFunctions.has(world_name):
		worldReadyFunctions[world_name].call_func(world_name)
