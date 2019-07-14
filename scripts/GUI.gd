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
			get_node("CanvasLayer/InventoryButton/InventoryButton").normal = preload("res://assets/UI/inventory/bag.png")
			get_node("CanvasLayer/InventoryButton/InventoryButton").pressed = preload("res://assets/UI/inventory/bag.png")
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
	get_node("CanvasLayer/moveButton")._playerBody.direction = 0
	get_node("CanvasLayer/moveButton")._playerBody.speed = 0
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