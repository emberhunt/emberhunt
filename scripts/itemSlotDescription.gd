extends Control

const Item = preload("res://scripts/Item.gd")

onready var descriptionLabel = $RichTextLabel

func _ready():
	descriptionLabel.bbcode_enabled = true


func set_description(item : Item):
	
	var bbCode = "[u]%s[/u]" % item.get_name()
	bbCode += "\n"
	bbCode += "%s" % item.get_description()
	bbCode += "\n"
	bbCode += "\n"
	
	if not item.get_effects().empty():
		var effects = item.get_effects()
		if effects.size() > 1:
			bbCode += "[color=green]Effects[/color]:"
		else:
			bbCode += "[color=green]Effect[/color]:"
		bbCode += "\n"
		for i in range(effects.size()):
			var effKey = effects.keys()[i]
			var effVal = effects[effKey]
			bbCode += "%s: %s\n" % [effKey, effVal]
	
	
	# ToDo:
	# - change color if player meets requirement
	if not item.get_requirements().empty():
		var requirements = item.get_requirements()
		if requirements.size() > 1:
			bbCode += "[color=red]Requirements[/color]:"
		else:
			bbCode += "[color=red]Requirement[/color]:"
		bbCode += "\n"
		for i in range(requirements.size()):
			var reqKey = requirements.keys()[i]
			var reqVal = requirements[reqKey]
			bbCode += "%s: %s\n" % [reqKey, reqVal]
			
	if item.is_sellable():
		bbCode += "\n"
		bbCode += "value: %s gold" % item.get_value()
		
	if item.is_consumable():
		bbCode += "\n"
		bbCode += "[i]Drag item to player in order to use it.[/i]"
	bbCode += "\n"
	

#%s
#
#[color=aqua]Effect:[/color] [b]deals a lot of damage[/b] [i]mehl[/i] [i][b]fant[/b][/i]
#
#[color=green]Requirement fulfilled[/color]: [b]10[/b]
#[color=red]Requirement NOT fulfilled[/color]: [b]10[/b]
#""" % item.get_description()

	descriptionLabel.bbcode_text = bbCode
	