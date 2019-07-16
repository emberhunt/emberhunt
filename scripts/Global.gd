# Copyright 2019 Emberhunt Team
# https://github.com/emberhunt
# Licensed under the GNU General Public License v3.0 or later
# SPDX-License-Identifier: GPL-3.0-or-later

extends Node


# Default settings
var boolSound = true
var Sound = 1
var boolMusic = true
var Music = 1
var quality = "High" # High, Medium, Low
var touchpadPosition = "Fixed"
var UUID = false

var nickname = "Offline"

var charactersData = {}

var charID = 0

var worldReadyFunctions = {}

var loaded_bullets = {}
var loaded_item_sprites = {}
var loaded_class_sprites = {}

var init_stats = {}
var items = {}
var item_types = {}

var world_data = {"players" : {}, "bags" : {}, "enemies" : {}, "npc" : {}}

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

func _ready():
	loadGame() # load settings
	_load_bullets()
	_load_item_sprites()
	_load_class_sprites()
	
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
	node.set_name("bags")
	get_node("/root/"+world_name+"/Entities").add_child(node)
	node = YSort.new()
	node.set_name("npc")
	get_node("/root/"+world_name+"/Entities").add_child(node)
	
	# Spawn bags
	for bag_pos in world_data.bags.keys():
		var bag_instance = preload("res://scenes/inventory/Bag.tscn").instance()
		bag_instance.position = bag_pos
		get_node("/root/"+world_name+"/Entities/bags").add_child(bag_instance)
	

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
	if directory.open("res://assets/UI/inventory/items/") == OK:
		directory.list_dir_begin()
		var file_name = directory.get_next()
		while( file_name != ""):
			# Godot is weird
			if file_name.ends_with(".import"):
				loaded_item_sprites[file_name.trim_suffix(".import")] = load("res://assets/UI/inventory/items/"+file_name.replace(".import",""))
			file_name = directory.get_next()
	else:
		print("Error opening res://assets/UI/inventory/items/")

func _load_class_sprites():
	var directory = Directory.new()
	if directory.open("res://assets/classes") == OK:
		directory.list_dir_begin()
		var file_name = directory.get_next()
		while( file_name != ""):
			if file_name.ends_with(".import"):
				loaded_class_sprites[file_name.trim_suffix(".import")] = load("res://assets/classes/"+file_name.replace(".import",""))
			file_name = directory.get_next()
	else:
		print("Error opening res://assets/classes/")

func get_item_sprite(item_id):
	var size
	var not_found
	if quality == "High":
		size = "_216x216"
		not_found = preload("res://assets/UI/sprite_not_found_216x216.png")
	elif quality=="Medium":
		size = "_108x108"
		not_found = preload("res://assets/UI/sprite_not_found_108x108.png")
	else:
		size = "_54x54"
		not_found = preload("res://assets/UI/sprite_not_found_54x54.png")
	if items[ item_id ].has("icon"):
		var file_name = items[ item_id ].icon.get_basename()+size+"."+items[ item_id ].icon.get_extension()
		if loaded_item_sprites.has(file_name):
			return loaded_item_sprites[ file_name ]
	return not_found

func get_class_sprite(className):
	var size
	var not_found
	if quality == "High":
		size = "_216x216"
		not_found = preload("res://assets/UI/sprite_not_found_216x216.png")
	elif quality=="Medium":
		size = "_108x108"
		not_found = preload("res://assets/UI/sprite_not_found_108x108.png")
	else:
		size = "_54x54"
		not_found = preload("res://assets/UI/sprite_not_found_54x54.png")
	
	if init_stats.has(className):
		var file_name = className.capitalize()+size+".png"
		if loaded_class_sprites.has(file_name):
			return loaded_class_sprites[ file_name ]
	return not_found

func find_position_for_bag():
	# We will pick a random position that is near enough
	# We cannot risk on generating a position that some bag already has
	# So we will put this in a loop
	var player_pos = get_node("/root/"+get_tree().get_current_scene().get_name()+"/Entities/player").position
	while true:
		randomize()
		var rotation = rand_range(-PI, PI)
		var vector_from_playernode = Vector2(sin(rotation), -cos(rotation))*11
		# Check if there's already a bag on the generated position
		if vector_from_playernode+player_pos in Global.world_data.bags.keys():
			continue
		return vector_from_playernode