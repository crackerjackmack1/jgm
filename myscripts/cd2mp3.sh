#!/bin/bash
# cd2mp3.sh: Converts Audio CD into a single MP3
# License: GNU General Public License v.3

################################################################################
# Copyright (C) 2019 Crackerjack                                               #
#                                                                              #
# This program is free software; you can redistribute it and/or modify         #
# it under the terms of the GNU General Public License as published by         #
# the Free Software Foundation; either version 3 of the License, or            #
# (at your option) any later version.                                          #
#                                                                              #
# This program is distributed in the hope that it will be useful, but          #
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY   #
# or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License      #
# for more details.                                                            #
#                                                                              #
# You should have received a copy of the GNU General Public License along      #
# with this program; if not, write to the Free Software Foundation, Inc.,      #
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.                  #
#                                                                              #
# Created in UBUNTU 16.04.3 LTS (Bionic Beaver) 64-bit, MATE 1.20.1, Kernel    #
# Linux 5.0.0-36-generic x86_64, GNU bash, version 4.4.20(1)-release (x86_64-  #
# pc-linux-gnu), Audacity 2.2.1.                                               #
#                                                                              #
# This script utilizes 'ffmpeg' to convert CD-ROM tracks into mp3's then       #
# concatenates and saves them all to an output file on the users ~/Desktop.    #
# The output file is then automatically opened in "Audacity" so the user can   #
# "Normalize" & "Export" the compiled MP3. The CD is then ejected. The final   #
# MP3 file name argument is "Required", however the destination argument is    #
# optional.                                                                    #
#                                                                              #
# IMPORTANT! Arguments cannot contain whitespace characters!                   #
# Example: ./cd2mp3.sh "Abbey_Road.mp3" "$HOME/Music/Abby_Road"                #
#                                                                              #
# It is strongly suggested to install Audacity and "fine tuning" the MP3 by    #
# running the "Effect" > "Normalize" filter with the following settings:       #
# ✓"Remove DC offset" ✓"Normalize to -1.0 dB" ✓"Normalize stereo channels"   #
#                                                                              #
# Enjoy!                                                                       #
#                                                                              #
################################################################################

CDSRC="/run/user/1000/gvfs/cdda:host=sr0"           # CD device directory
CDFILES="/run/user/1000/gvfs/cdda:host=sr0/*.wav"   # CD wav files
MP3_NAME=$1
MP3_DEST=$2
E_NOARGS=85
E_NOCD=86
SCRIPT_NAME=${0%'.sh'}
SCRIPT_NAME=${SCRIPT_NAME#'./'}

#resize -s 36 140

# Checks for "filename" argument and exits if not found
if [ -z "$MP3_NAME" ]
then
    echo -e "\033[1mUsage:\033[0m \033[1;33m`basename $0`\033[0m \033[1m[filename]  [destination]\033[0m"
    echo "                 \"Required\"   \"Optional\""
    echo
    exit $E_NOARGS
fi

# Checks for "destination" argument and sets default if not found
if [ -z "$MP3_DEST" ]
then
    MP3_DEST="$HOME/Desktop"
fi

echo

# Checks for "CD-ROM/files" and exits if not found
if [ ! -d "$CDSRC" ]
then
   echo -e "\033[1;33mDISK NOT FOUND!\033[0m"
   echo "Check for:"
   echo "     Disk in drive"
   echo "     CD-ROM connection"
   exit $E_NOCD
fi

# Get file count...
filecount=0
for each in $CDFILES
do (( filecount += 1 )); done

echo

if [ -d "$CDSRC" ]
then
    echo -e "\033[1mCreating: $HOME/Music/$SCRIPT_NAME\033[0m"
    sleep 1
    mkdir "$HOME/Music/$SCRIPT_NAME"
    sleep 1
    echo "Done!"
    echo
    sleep 1
    echo -e "\033[1mCD-ROM contains $filecount Track(s)\033[0m"
    sleep 1
    echo
fi

sleep 3

for n in `seq $filecount`
do
    echo -e "\033[1;33m-------------------------------------------------\033[0m"
    echo -e "\033[1;33m Converting \"Track $n.wav\" to \"Track_$n.mp3\" \033[0m"
    echo -e "\033[1;33m-------------------------------------------------\033[0m"
    echo
    `ffmpeg -hide_banner -i "/run/user/1000/gvfs/cdda:host=sr0/Track $n.wav" -ab 128k -ac 2 -ar 44100 "$HOME/Music/$SCRIPT_NAME/Track_$n.mp3"`
    sleep 1
    echo
done

sleep 3

eject

echo
echo -e "\033[1;33m-------------------------------------------------\033[0m"
echo -e "\033[1;33m Concatenating $filecount file(s)                \033[0m"
echo -e "\033[1;33m-------------------------------------------------\033[0m"
echo

sleep 3

echo

audio="-ab 128k -ac 2 -ar 44100"
outfile="$MP3_DEST/$MP3_NAME"
com=""
for n in `seq $filecount`
do
    com+=$HOME/Music/$SCRIPT_NAME/Track_$n.mp3
    if [ $n != $filecount ]
    then
        com+="|"
    fi
done

echo -e "\033[1mWriting file to $MP3_DEST\033[0m"

`ffmpeg -hide_banner -i concat\:$com $audio $outfile`

sleep 3

# echo

# If Outfile exists
if [ -e "$outfile" ]
then
    echo
    echo -e "\033[1;33m-------------------------------------------------\033[0m"
    echo -e "\033[1;33m Cleaning up file(s)                             \033[0m"
    echo -e "\033[1;33m-------------------------------------------------\033[0m"
    echo
    
    # Remove directory & contents
    rm -dr "$HOME/Music/$SCRIPT_NAME"
    
    sleep 3
    
    # Edit in Audacity for "Effect:Normalize" & "File:Export as MP3"
    exec audacity $outfile
else
    echo -e "\033[1mAN UNKNOWN ERROR OCCURED!\033[0m"
    exit $?
fi

exit 0
