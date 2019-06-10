# Copyright 2019 Emberhunt Team
# https://github.com/emberhunt
# Licensed under the GNU General Public License v3.0 or later
# SPDX-License-Identifier: GPL-3.0-or-later

func listargs(args = [], mainServer = null):
	var returnValue = "Arguments used in this command:\n"
	for arg in args:
		returnValue += "* "+arg+"\n"
	return returnValue