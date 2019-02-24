extends Control


onready var descriptionLabel = $RichTextLabel

func _ready():
	descriptionLabel.bbcode_enabled = true


func set_description(description : String):
	var bbCode = """[u]Item_Test_Name[/u]

%s

[color=aqua]Effect:[/color] [b]deals a lot of damage[/b] [i]mehl[/i] [i][b]fant[/b][/i]

[color=green]Requirement fulfilled[/color]: [b]10[/b]
[color=red]Requirement NOT fulfilled[/color]: [b]10[/b]
""" % description
	descriptionLabel.bbcode_text = bbCode
	