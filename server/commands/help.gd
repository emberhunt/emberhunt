# Copyright 2019 Emberhunt Team
# https://github.com/emberhunt
# Licensed under the GNU General Public License v3.0 or later
# SPDX-License-Identifier: GPL-3.0-or-later


var _short_description = "displays a manual for a specific command"

var _description = """displays a manual for a specific command

USAGE:	help [command]"""


func help(args = [], mainServer = null):
	if mainServer == null:
		return "Instance of MainServer.gd is invalid"
	
	if args.size() == 0:
		# Get the list of all commands
		var files = []
		var dir = Directory.new()
		dir.open("res://server/commands")
		dir.list_dir_begin(true)
		var file = dir.get_next()
		while file:
			if file.ends_with(".gd"):
				files.append(file.rstrip(".gd"))
			file = dir.get_next()
		files.sort()
		
		# Get the description of each command
		var output = "Here's some help:\n\n\tList of commands:"
		for command in files:
			var command_description = "not defined."
			var command_script = load("res://server/commands/"+command+".gd").new()
			# Check if the command has a description defined
			var properties = []
			for property in command_script.get_property_list():
				properties.append(property.name)
			if "_short_description" in properties:
				command_description = command_script._short_description
			output += "\n\t* "+command+" - "+command_description
		return output
	elif args.size() > 1:
		return "help: Too many arguments!"
	else:
		# Check if a command with specified name exists
		var file = File.new()
		if file.file_exists("res://server/commands/"+args[0]+".gd"):
			var command_description = "not defined."
			var command_script = load("res://server/commands/"+args[0]+".gd").new()
			# Check if the command has a description defined
			var properties = []
			for property in command_script.get_property_list():
				properties.append(property.name)
			if "_description" in properties:
				command_description = command_script._description
			return "\n"+args[0]+" -- "+command_description
		else:
			return "help: There's no help page for this command ("+args[0]+")"