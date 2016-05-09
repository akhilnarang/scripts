#!/bin/bash
#
# Copyright � 2015-2016, Akhil Narang "akhilnarang" <akhilnarang.1999@gmail.com>
# rsync Script For ThugLife Kernel
#
# This software is licensed under the terms of the GNU General Public
# License version 2, as published by the Free Software Foundation, and
# may be copied, distributed, and modified under those terms.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# Please maintain this if you use this script or any part of it
#

export LOCAL_FILES="$THUGDIR/files/bullhead/";
[[ -d "${LOCAL_FILES}" ]] || mkdir -p ${LOCAL_FILES}
echo -e "Starting at $(date)"
echo -e "Sync bullhead files with SourceForge.net?";
echo -e "Local files are :"
ls $LOCAL_FILES;
echo -e "Enter 1 to upload, anything else not to";
read ch;
if [ "$ch" == "1" ];
then
rsync -av -e ssh $LOCAL_FILES/ akhilnarang@frs.sourceforge.net:/home/frs/project/thuglife/bullhead/
fi

echo -e "Sync bullhead files from SourceForge.net here?";
echo -e "Enter 1 to download, anything else to not";
read ch;
if [ "$ch" == "1" ];
then
rsync -av -e ssh akhilnarang@frs.sourceforge.net:/home/frs/project/thuglife/bullhead/ $LOCAL_FILES/
fi

echo -e "End of script"
