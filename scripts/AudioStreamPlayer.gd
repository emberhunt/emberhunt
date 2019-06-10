# Copyright 2019 Emberhunt Team
# https://github.com/emberhunt
# Licensed under the GNU General Public License v3.0 or later
# SPDX-License-Identifier: GPL-3.0-or-later

extends AudioStreamPlayer

func _process(delta):
	# If finished playing delete itself
	if not is_playing():
		queue_free()
	pass