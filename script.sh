#! /bin/bash

if [ "$1" != "" ]; then
	echo '1:repo sync and build, 2:build'
	read choice
	if [ "$choice" == "1" ]; then
		eval "cd ~/android"
		eval "repo sync -j16"
	elif [ "$choice" == "2" ]; then
		eval "cd ~/android"
	fi
		eval ". build/envsetup.sh"
		eval "export USE_PREBUILT_CHROMIUM=1"
		eval "export USE_CCACHE=1"
		eval "breakfast $1"
else
	echo "error: enter device name"
fi
