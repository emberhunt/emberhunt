# Copyright 2019 Emberhunt Team
# https://github.com/emberhunt
# Licensed under the GNU General Public License v3.0 or later
# SPDX-License-Identifier: GPL-3.0-or-later

extends Control

onready var debugLabel = $CanvasLayer/debugLabel 
onready var fpsLabel = $CanvasLayer/FPS

export(NodePath) var playerNode = "../Entities/player"

var playerBody : KinematicBody2D = null

var near_a_bag = false
var last_bag = null

var buff_indicators = {}
#				"strength_pos" : Node

var characterInfoWindow_open = false

func _ready():
	playerBody = get_node("../Entities/player")
	
	$CanvasLayer/moveButton.init(playerBody)
	$CanvasLayer/shootButton.init(playerBody.get_node("weapon"))

func sort_by_distance(a, b):
	return (a-playerBody.position).length() < (b-playerBody.position).length()

func _process(delta):
	# For debugging:
	debugLabel.set_text(str(playerBody.get_position()))
	if delta != 0:
		fpsLabel.set_text("FPS: "+str(round(1/delta)))
	
	# Update health/mana/exp bars
	$CanvasLayer/StatusBars/hp.value = float(Global.player_data.hp)/float(Global.charactersData[Global.charID].max_hp+ \
		Global.buffs_sum(Global.player_data.buffs.max_hp))
	$CanvasLayer/StatusBars/mp.value = float(Global.player_data.mp)/float(Global.charactersData[Global.charID].max_mp+ \
		Global.buffs_sum(Global.player_data.buffs.max_mp))
	get_node("CanvasLayer/StatusBars/exp").value = float(Global.charactersData[Global.charID].experience)/floor(200*pow(1.15, Global.charactersData[Global.charID].level-1))
	# Minibar
	get_node("/root/"+get_tree().get_current_scene().get_name()+"/Entities/player/minihp").value = float(Global.player_data.hp)/float(Global.charactersData[Global.charID].max_hp+ \
		Global.buffs_sum(Global.player_data.buffs.max_hp))
	
	# Buff indicators
	var processed_indicators = []
	for stat in Global.player_data.buffs.keys():
		var sum = 0
		for buff in Global.player_data.buffs[stat]:
			sum += buff[0]
		if sum == 0:
			continue
		var id = stat+("_pos" if sum > 0 else "_neg")
		if not buff_indicators.has(id):
			var indicator = preload("res://scenes/Buff_Indicator.tscn").instance()
			indicator.texture = Global.loaded_buff_indicators[id]
			get_node("CanvasLayer/BuffIndicators").add_child(indicator)
			buff_indicators[id] = indicator
		processed_indicators.append(buff_indicators[id])
	# Remove expired buff indicators
	for indicator in get_node("CanvasLayer/BuffIndicators").get_children():
		if not (indicator in processed_indicators):
			buff_indicators.erase(buff_indicators.keys()[buff_indicators.values().find(indicator)])
			indicator.queue_free()
	
	
	# Check if there's a bag near enough for the player to view it's contents
	var bags = []
	for bag_pos in Global.world_data.bags.keys():
		# Make sure it's not a private bag
		if not Global.world_data.bags[bag_pos].has("player") or ( Global.world_data.bags[bag_pos].has("player") and Global.world_data.bags[bag_pos].player==get_tree().get_network_unique_id() ):
			bags.append(bag_pos)
	# Sort the bags by distance from the player
	bags.sort_custom(self, "sort_by_distance")
	
	# Check if the closest bag is close enough
	if bags.size()!=0 and (bags[0]-playerBody.position).length()<=12:
		# It is! Yay!
		
		# If this bag is not the same as last frame, highlight it
		if bags[0] != last_bag:
			highlight_bag(bags[0])
		last_bag = bags[0]
		
		# Change the sprite of the inventory button to tell the player
		# That they can view the bag
		if not near_a_bag:
			get_node("CanvasLayer/InventoryButton/InventoryButton").normal = preload("res://assets/UI/inventory/bag_button.png")
			get_node("CanvasLayer/InventoryButton/InventoryButton").pressed = preload("res://assets/UI/inventory/bag_button.png")
			near_a_bag = true
	else:
		# If there was a bag last frame, but now isn't remove all highlights
		if last_bag != null:
			highlight_bag()
		last_bag = null
		
		# Change the inventory button sprite back to normal
		if near_a_bag:
			get_node("CanvasLayer/InventoryButton/InventoryButton").normal = preload("res://assets/UI/inventory/inventory_icon.png")
			get_node("CanvasLayer/InventoryButton/InventoryButton").pressed = preload("res://assets/UI/inventory/inventory_icon.png")
			near_a_bag = false

func _on_PauseButton_pressed():
	if not Global.paused:
		Global.paused = true
		SoundPlayer.play(preload("res://assets/sounds/click.wav"))
		var scene = preload("res://scenes/PauseMenu.tscn")
		var scene_instance = scene.instance()
		scene_instance.set_name("PauseMenu")
		$CanvasLayer.add_child(scene_instance)
		# disable touchads
		setTouchpadsState(false)


func setTouchpadsState(state):
	get_node("CanvasLayer/moveButton").disabled = !state
	get_node("CanvasLayer/moveButton").isPressed = false
	get_node("CanvasLayer/moveButton")._playerBody.direction = Vector2(0,0)
	#get_node("CanvasLayer/moveButton")._playerBody.speed = 0
	get_node("CanvasLayer/moveButton/buttonSprite").hide()
	get_node("CanvasLayer/moveButton/background").hide()
	get_node("CanvasLayer/shootButton").disabled = !state
	get_node("CanvasLayer/shootButton").isPressed = false
	get_node("CanvasLayer/shootButton")._weaponNode.rotation = 0
	get_node("CanvasLayer/shootButton")._weaponNode.attacking = false
	get_node("CanvasLayer/shootButton/buttonSprite").hide()
	get_node("CanvasLayer/shootButton/background").hide()


func _on_InventoryButton_pressed():
	if not Global.paused:
		SoundPlayer.play(preload("res://assets/sounds/click.wav"))
		if not get_node("CanvasLayer").has_node("Inventory"):
			# Open:
			var scene
			# Note that the these scenes contain the same scripts.
			if not near_a_bag:
				scene = preload("res://scenes/inventory/Inventory.tscn")
			else:
				scene = preload("res://scenes/inventory/InventoryAndBag.tscn")
			var scene_instance = scene.instance()
			scene_instance.set_name("Inventory")
			$CanvasLayer.add_child(scene_instance)
			# disable touchads
			setTouchpadsState(false)
		else:
			# Close:
			
			get_node("CanvasLayer/Inventory").queue_free()
			setTouchpadsState(true)

func highlight_bag(bag_pos = null):
	# First remove the highlight from the last bag, if there is one
	for bag_node in get_node("/root/"+get_tree().get_current_scene().get_name()+"/Entities/bags").get_children():
			if bag_node.scale.x != 1:
				bag_node.texture = preload("res://assets/UI/inventory/bag.png")
				bag_node.scale = Vector2(1.0,1.0)
				break
	
	# Then, if NULL was passed, do nothing
	if bag_pos == null:
		return
	# Otherwise highlight the bag
	for bag_node in get_node("/root/"+get_tree().get_current_scene().get_name()+"/Entities/bags").get_children():
			if bag_node.position == bag_pos:
				if Global.quality == "High":
					bag_node.texture = preload("res://assets/UI/inventory/bag_outline_192x192.png")
					bag_node.scale = Vector2(1.0/12.0, 1.0/12.0)
				elif Global.quality == "Medium":
					bag_node.texture = preload("res://assets/UI/inventory/bag_outline_96x96.png")
					bag_node.scale = Vector2(1.0/6.0, 1.0/6.0)
				else:
					bag_node.texture = preload("res://assets/UI/inventory/bag_outline_48x48.png")
					bag_node.scale = Vector2(1.0/3.0, 1.0/3.0)
				break

func display_gain(gain):
	var gain_scene = preload("res://scenes/StatGains.tscn").instance()
	gain_scene.init(gain)
	get_node("CanvasLayer").add_child(gain_scene)


func _on_StatusBars_pressed():
	if not Global.paused:
		if not characterInfoWindow_open:
			var characterInfoWindow = preload("res://scenes/CharacterInfoWindow.tscn").instance()
			# Set the window up with relevant info
			characterInfoWindow.get_node("CharacterSprite").texture = Global.loaded_class_sprites[Global.charactersData[Global.charID]["class"].capitalize()+"_216x216.png"]
			characterInfoWindow.get_node("class").set_text(str(Global.charactersData[Global.charID]["class"]))
			characterInfoWindow.get_node("_level/level").set_text(str(Global.charactersData[Global.charID]["level"]))
			for stat in Global.charactersData[Global.charID].keys():
				if not (stat in ["experience", "inventory", "class", "level"]):
					var parent
					if stat in ["max_hp","strength","magic","physical_defense"]:
						parent = characterInfoWindow.get_node("_left")
					else:
						parent = characterInfoWindow.get_node("_right")
					if Global.buffs_sum(Global.player_data.buffs[stat]) > 0:
						parent.get_node(stat).set("custom_colors/font_color", Color8(69, 246, 34))
						parent.get_node(stat).set_text(str(Global.charactersData[Global.charID][stat]+Global.buffs_sum(Global.player_data.buffs[stat]))+" (+"+str(Global.buffs_sum(Global.player_data.buffs[stat]))+")")
					elif Global.buffs_sum(Global.player_data.buffs[stat]) < 0:
						parent.get_node(stat).set("custom_colors/font_color", Color8(246, 34, 34))
						parent.get_node(stat).set_text(str(Global.charactersData[Global.charID][stat]+Global.buffs_sum(Global.player_data.buffs[stat]))+" (+"+str(Global.buffs_sum(Global.player_data.buffs[stat]))+")")
					else:
						parent.get_node(stat).set_text(str(Global.charactersData[Global.charID][stat]))
			characterInfoWindow.get_node("nickname").set_text(Global.nickname)
			get_child(0).add_child(characterInfoWindow)
			characterInfoWindow_open = true

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and characterInfoWindow_open and not Global.paused:
			get_node("CanvasLayer/CharacterInfoWindow").queue_free()
			characterInfoWindow_open = false