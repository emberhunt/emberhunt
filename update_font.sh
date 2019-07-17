#!/bin/bash

# Copyright 2019 Emberhunt Team
# https://github.com/emberhunt
# Licensed under the GNU General Public License v3.0 or later
# SPDX-License-Identifier: GPL-3.0-or-later

echo "Fetching the latest commit info from GitHub."

REMOTE_COMMITS=$(curl -s "https://api.github.com/repos/emberhunt/emberfont/commits")
REMOTE_COMMITS=$(printf "$REMOTE_COMMITS")
LOCAL_COMMITS=$(cat ./assets/emberfont/version.txt)

if [ "$REMOTE_COMMITS" = "$LOCAL_COMMITS" ] ; then
	echo "The font is already up to date."
else
	echo "Updating..."
	if (wget -nv --no-check-certificate --content-disposition https://github.com/emberhunt/emberfont/raw/master/emberfont.ttf -O assets/emberfont/emberfont.ttf.part) ; then
		echo "Download complete."
		rm assets/emberfont/emberfont.ttf
		mv assets/emberfont/emberfont.ttf.part assets/emberfont/emberfont.ttf
		printf "$REMOTE_COMMITS" > assets/emberfont/version.txt
		echo "Update successful."
	else
		echo "Font download failed."
	fi
fi