"""

"""
tool
extends Control

onready var debugLabel = $CanvasLayer/debugLabel 

export(NodePath) var playerNode

onready var inventorySystem = $inventorySystem
var playerBody : KinematicBody2D = null



func _ready():
	set_process_input(true)
	inventorySystem.hide()
	playerBody = get_node(playerNode).get_child(0)
	
	get_node("moveButton").init(playerBody)
	get_node("shootButton").init(playerBody.get_node("weapon"))
	pass 


func _input(event):
	if event is InputEventKey and event.scancode == KEY_I and event.is_pressed() and not event.echo:
		print("visible")
		inventorySystem.visible = ! inventorySystem.visible
		
func _process(delta):
	if playerBody != null:
		debugLabel.set_text(str(playerBody.get_position()))
	