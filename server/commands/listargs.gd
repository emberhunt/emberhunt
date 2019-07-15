# Copyright 2019 Emberhunt Team
# https://github.com/emberhunt
# Licensed under the GNU General Public License v3.0 or later
# SPDX-License-Identifier: GPL-3.0-or-later


var _short_description = "displays a manual for a specific command"

var _description = """lists the arguments you use

USAGE:	listargs arg1 arg2 arg3 ...

This command is used to check if you type your arguments correctly."""


func listargs(args = [], mainServer = null):
	var returnValue = "Arguments used in this command:\n"
	for arg in args:
		returnValue += "* "+arg+"\n"
	return returnValue