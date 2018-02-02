#!/usr/bin/env bash
#
# Build Script To Compile Android ROMs

# Place Script in root of source.

# Folder name on upload server.
rom="temasek"

# Fixes the fact that android needs python2, arch has 3 by default, and a newer flex version.
export LC_ALL="C"
virtualenv2 venv
source venv/bin/activate

# Setup environment. Check README of lazy directory to find out about credentials.
source build/envsetup.sh
source ../.credentials

# 1st parameter - device to be built.
breakfast $1

# 2nd parameter. Pass a target to be made, like clean, clobber, dirty, installclean, etc. If none, will delete old zips, build.prop, kernel's .version
if [ $2 ];
then
mka $2
else
rm -f $OUT/*.zip $OUT/system/build.prop $OUT/obj/KERNEL_OBJ/.version >/dev/null
fi

# Most likely not needed. CM has it, can be used as a sort of tag for unofficial builds. Using here, coz temasek needs it for the zips to be properly named :)
export TARGET_UNOFFICIAL_BUILD_ID=$rom

# Make a directory to store log files if one dosen't exist
[ ! -d logs ] || mkdir logs

# Check for target to be built
if [ $(grep ^bacon build/core/Makefile) ];
then
makecommand=bacon;
else
makecommand=otapackage;
fi

# Build ang log output
time mka $makecommand 2>&1 | tee logs/$rom-$1-$(date +%Y%m%d).log

# Get full path to zip, zipname, and declare path on upload server.
pathzip=$(ls $OUT/*.zip | head -1)
zip=$(basename ${pathzip})
path="$rom/$1/"

# Not needed for most guys.
# I have a symlink to ~/web in my apache2 webroot, so I can server files from my server, hence I copy the files there :).
#[ ! -d ~/web/$path ] || mkdir -p ~/web/$path
#cp -v $pathzip ~/web/$path/

# Have a script in ~/bin, explained in README. In this case script is called rwh, I'm uploading to romwarehouse.com :).
rwh $pathzip $path
bitlyarg1="${rwhlink}${path}${zip}"
echo $bitlyarg1

# Another script, which uses bitly.com API to make a short url :).
bitly $bitlyarg1
echo "";

# Again, related to my serving of files directly from the server
#bitlyarg2="${phoenixlink}${path}${zip}"
#echo $bitlyarg2
#bitly $bitlyarg2
#echo "";
echo "md5sum is $(md5sum $pathzip | awk '{print $1}')";
figlet thuglife
