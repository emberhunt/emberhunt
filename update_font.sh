#!/bin/bash

# Copyright 2019 Emberhunt Team
# https://github.com/emberhunt
# Licensed under the GNU General Public License v3.0 or later
# SPDX-License-Identifier: GPL-3.0-or-later

REMOTE_COMMITS=$(curl -s "https://api.github.com/repos/emberhunt/emberfont/commits" | jq length)
REMOTE_COMMITS=$(($REMOTE_COMMITS+0))
LOCAL_COMMITS=$(cat ./assets/emberfont/version.txt)
LOCAL_COMMITS=$(($LOCAL_COMMITS+0))

if [ "$REMOTE_COMMITS" -gt "$LOCAL_COMMITS" ] ; then
	echo "Updating..."
	if (wget -nv --no-check-certificate --content-disposition https://github.com/emberhunt/emberfont/raw/master/emberfont.ttf -O assets/emberfont/temp_emberfont.ttf) ; then
		echo "Download complete."
		rm assets/emberfont/emberfont.ttf
		mv assets/emberfont/temp_emberfont.ttf assets/emberfont/emberfont.ttf
		printf $REMOTE_COMMITS > assets/emberfont/version.txt
		echo "Update successful."
	else
		echo "Font download failed."
	fi
else
	echo "The font is already up to date."
fi