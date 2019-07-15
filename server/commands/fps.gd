# Copyright 2019 Emberhunt Team
# https://github.com/emberhunt
# Licensed under the GNU General Public License v3.0 or later
# SPDX-License-Identifier: GPL-3.0-or-later


var _short_description = "displays server's current FPS."

var _description = """displays server's current FPS. If not lagging, should always be ~60"""


func fps(args = [], mainServer = null) -> String:
	return "Server FPS: "+str(Engine.get_frames_per_second())