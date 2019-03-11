extends Node


# Default settings
var boolSound = true
var Sound = 1
var boolMusic = true
var Music = 1
var quality = "High" # High, Medium, Low
var touchpadPosition = "Fixed"
var UUID = false

# When not testing leave just {}, the server will send this data later
var charactersData = {}#{0:{"class" : "Mage", "level" : 47},1:{"class" : "Knight", "level" : 1}}

# data of all items loaded once
var allItems = {}

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
	file.open("res://assets/inventory/PlayerInventory.json", file.READ)
	var dataText = file.get_as_text()
	file.close()
	var data = JSON.parse(dataText)
	
	if data.error != OK:
		get_node("/root/Console").write_line("[color=red]couldn't load items![/color]")
		return
	else:
		get_node("/root/Console").write_line("[color=yellow]loading items was successful![/color]")
		
		#print("Problems loading " + fileName + " (in Inventory.gd)")

	data = data.result
	for i in range(data.size()):
		var itemData = data[str(i)]
		var newItem = Item.new(
				i,
				itemData["name"], 
				Item.get_type_from_name(itemData["type"]),
				itemData["weight"],
				itemData["value"],
				itemData["effects"],
				itemData["requirements"],
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
				
		allItems[i] = newItem
		
func _ready():
	loadGame()
	loadItems()