"""

"""
tool
extends Control

onready var debugLabel = $CanvasLayer/debugLabel 

export(NodePath) var playerNode = "../player"

onready var inventorySystem = $inventorySystem
var playerBody : KinematicBody2D = null


func _ready():
	set_process_input(true)
	inventorySystem.hide()
	playerBody = get_node(playerNode).get_child(0)
	
	$moveButton.init(playerBody)
	$shootButton.init(playerBody.get_node("weapon"))


func _input(event):
	if event is InputEventKey and event.scancode == KEY_I and event.is_pressed() and not event.echo:
		#print("visible")
		inventorySystem.visible = ! inventorySystem.visible
		
func _process(delta):
	if playerBody != null:
		debugLabel.set_text(str(playerBody.get_position()))
	

func _on_TouchScreenButton_pressed():
	if not Global.paused:
		Global.paused = true
		SoundPlayer.play(preload("res://assets/sounds/click.wav"))
		var scene = preload("res://scenes/PauseMenu.tscn")
		var scene_instance = scene.instance()
		scene_instance.set_name("PauseMenu")
		$CanvasLayer.add_child(scene_instance)
		# Disable touchpads
		get_node("moveButton").disabled = true
		get_node("shootButton").disabled = true
