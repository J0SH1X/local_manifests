#!/bin/bash

#    BlissPop  Compilation Script
#
#    Copyright (C) 2015 Team Bliss
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.


# No scrollback buffer
echo -e '\0033\0143'



# Get intial time of script startup
res1=$(date +%s.%N)



# Specify colors for shell
red='tput setaf 1'              # red
green='tput setaf 2'            # green
yellow='tput setaf 3'           # yellow
blue='tput setaf 4'             # blue
violet='tput setaf 5'           # violet
cyan='tput setaf 6'             # cyan
white='tput setaf 7'            # white
txtbld=$(tput bold)             # Bold
bldred=${txtbld}$(tput setaf 1) # Bold red
bldgrn=${txtbld}$(tput setaf 2) # Bold green
bldblu=${txtbld}$(tput setaf 4) # Bold blue
bldcya=${txtbld}$(tput setaf 6) # Bold cyan
normal='tput sgr0'

tput bold
tput setaf 1
clear
echo -e ""
echo -e "      ___           ___                   ___           ___           ___           ___           ___              "
echo -e "     /\  \         /\__\      ___        /\  \         /\  \         /\  \         /\  \         /\  \             "
echo -e "    /::\  \       /:/  /     /\  \      /::\  \       /::\  \       /::\  \       /::\  \       /::\  \            "
echo -e "   /:/\:\  \     /:/  /      \:\  \    /:/\ \  \     /:/\ \  \     /:/\:\  \     /:/\:\  \     /:/\:\  \           "
echo -e "  /::\~\:\__\   /:/  /       /::\__\  _\:\~\ \  \   _\:\~\ \  \   /::\~\:\  \   /:/  \:\  \   /::\~\:\  \          "
echo -e " /:/\:\ \:|__| /:/__/     __/:/\/__/ /\ \:\ \ \__\ /\ \:\ \ \__\ /:/\:\ \:\__\ /:/__/ \:\__\ /:/\:\ \:\__\         "
echo -e " \:\~\:\/:/  / \:\  \    /\/:/  /    \:\ \:\ \/__/ \:\ \:\ \/__/ \/__\:\/:/  / \:\  \ /:/  / \/__\:\/:/  /         "
echo -e "  \:\ \::/  /   \:\  \   \::/__/      \:\ \:\__\    \:\ \:\__\        \::/  /   \:\  /:/  /       \::/  /          " 
echo -e "   \:\/:/  /     \:\  \   \:\__\       \:\/:/  /     \:\/:/  /         \/__/     \:\/:/  /         \/__/           "  
echo -e "    \::/__/       \:\__\   \/__/        \::/  /       \::/  /                     \::/  /                          "
echo -e "     ~~            \/__/                 \/__/         \/__/                       \/__/                           "
echo -e ""
echo -e ""
echo -e ""
echo -e ""
echo -e ""

sleep 3s

TEAM_NAME="BlissPop"
TARGET=jfltexx
BP_VER=lp5.1
ALU_DIR=kernel/samsung/alucard24
FILENAME=bp-"$BP_VER"-"$(date +%Y%m%d)"-OPTIMIZED-"$TARGET"

buildROM () { 
    ## Start the build
    echo "Building";
    CPU_NUM=$[$(nproc)+1]
    time schedtool -B -n 1 -e ionice -n 1 make otapackage -j"$CPU_NUM" "$@"
}

repoSync(){
    ## Sync the repo
    echo "Syncing repositories"
    reposync

    if [ "$1" == "2" ]; then 
        echo "Upstream merging"
        ## local manifest location
        ROOMSER=.repo/local_manifests/local_manifest.xml
        # Lines to loop over
        CHECK=$(cat ${ROOMSER} | grep -e "<remove-project" | cut -d= -f3 | sed 's/revision//1' | sed 's/\"//g' | sed 's|/>||g')
        
        ## Upstream merging for forked repos
        while read -r line; do
            echo "Upstream merging for $line"
            cd  "$line"
            UPSTREAM=$(sed -n '1p' UPSTREAM)
            BRANCH=$(sed -n '2p' UPSTREAM)
            ORIGIN=$(sed -n '3p' UPSTREAM)
            PUSH_BRANCH=
            git pull https://www.github.com/"$UPSTREAM" "$BRANCH"
            git push "$ORIGIN" HEAD:opt-"$BRANCH"
            croot
        done <<< "$CHECK"
    fi
}

makeclean(){
    ## Fully wipe, including compiler cache
    echo "Cleaning ccache"
    ccache -C
    echo "Cleaning out folder"
    make clean
}

buildAlu() {
    cd "$ALU_DIR"
    ./build_kernel_cr_4.9.3.sh
    if [ "$?" == 0 ]; then
        echo "Alucard Kernel built, ready to repack"
    else
        echo "Alucard kernel build failure, do not repack"
    fi
    croot
}

repackRom() {
    LATEST=$(ls -t $OUT | grep -v .zip.md5 | grep .zip | head -n 1)
    TEMP=temp
    ALU_OUT="$ALU_DIR"/READY-JB

    mkdir "$TEMP"
    echo "Unpacking ROM to temp folder"
    unzip -q "$OUT"/"$LATEST" -d"$TEMP"
    echo "Copying Alucard Kernel"
    rm -rf "$TEMP"/system/lib/modules/*
    cp -r "$ALU_OUT"/system/lib/modules "$TEMP"/system/lib/modules
    cp "$ALU_OUT"/boot.img "$TEMP"

    cd "$TEMP"
    echo "Repacking ROM"
    zip -rq9 ../"$FILENAME".zip *
    cd ..
    echo "Creating MD5"
    md5sum "$FILENAME".zip > "$FILENAME".zip.md5
    echo "Cleaning up"
    rm -rf "$TEMP"
    echo "Done"
}

flashRom() {
    echo " "
    adb root
    sleep 3
    echo "pushing ROM file"
    adb push "$FILENAME".zip /sdcard/"$FILENAME".zip
    echo "pushing MD5"
    adb push "$FILENAME".zip.md5 /sdcard/"$FILENAME".zip.md5
    echo "install /sdcard/$FILENAME.zip" > openrecoveryscript
    echo "pushing open recovery script"
    adb remount
    adb push openrecoveryscript /cache/recovery/openrecoveryscript
    echo "rebooting phone"
    adb reboot recovery
}

anythingElse() {
    echo " "
    echo " "
    echo "Anything else?"
    select more in "Yes" "No"; do
        case $more in
            Yes ) bash build.sh; break;;
            No ) exit 0; break;;
        esac
    done ;
}

echo " "
echo " "
echo -e "\e[1;91mWelcome to the $TEAM_NAME build script"
echo -e "\e[0m "
echo "Setting up build environment..."
. build/envsetup.sh > /dev/null
echo "Setting build target $TARGET""..."
brunch "$TARGET" > /dev/null
echo " "
echo " "
echo -e "\e[1;91mPlease make your selections carefully"
echo -e "\e[0m "
echo " "
echo "Do you wish to build, sync or clean?"
select build in "Build ROM" "Sync" "Sync and upstream merge" "Build Alucard Kernel" "Repack ROM" "Make Clean" "Make Clean All (inc ccache)" "Push and flash" "Build ROM, Kernel and Repackage"; do
    case $build in
        "Build ROM" ) buildROM; anythingElse; break;;
        "Sync" ) repoSync 1; anythingElse; break;;
        "Sync and upstream merge" ) repoSync 2; anythingElse; break;;
        "Build Alucard Kernel" ) buildAlu; anythingElse; break;;
        "Repack ROM" ) repackRom; anythingElse; break;;
        "Make Clean" ) make clean; anythingElse; break;;
        "Make Clean All (inc ccache)" ) makeclean; anythingElse; break;;
        "Push and flash" ) flashRom; break;;
        "Build ROM, Kernel and Repackage"  ) buildROM; buildAlu; repackRom; anythingElse; break;;
    esac
done

exit 0
