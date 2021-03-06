#!/bin/sh
if [ $(id -u) != "0" ]; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi

DRIVE='/dev/sdc'
PART1=$DRIVE'1'
PART2=$DRIVE'2'

echo "Version:"
read IMGVERSION

echo "Zero root (y/N)?"
read ZEROROOT

MNT='/mnt/tmp'$IMGVERSION
MNT2='/mnt/tmp'$IMGVERSION'2'

cd /data/pi

mkdir $MNT
mkdir $MNT2
mount $PART1 $MNT
cp -r $MNT/config /tmp
rm -r $MNT/config
cp -r /data/pi/config $MNT
#apple
rm -r $MNT/.Trashes
rm -r $MNT/.fseventsd
rm -r $MNT/.Spotlight-V100
rm $MNT/._.Trashes
rm $MNT/*.DS_Store
rm -r $MNT/config/.Trashes
rm -r $MNT/config/.fseventsd
rm -r $MNT/config/.Spotlight-V100
rm $MNT/config/._.Trashes
rm $MNT/config/*.DS_Store

echo "Zero FAT"
#dd if=/dev/zero of=$MNT/zero bs=1M
rm $MNT/zero

mount $PART2 $MNT2
#remove network settings
rm $MNT2/var/lib/dhcp/*.leases
rm $MNT2/etc/udev/rules.d/*.rules
#logs
rm $MNT2/var/log/*
rm $MNT2/var/log/apt/*
#remove spotify/audio settings
rm -r $MNT2/root/.cache
rm -r $MNT2/root/.gstreamer-0.10
#security
rm $MNT2/root/.bash_history
#rm -r $MNT2/root/.ssh
#old stuff
rm -r $MNT2/boot.bk
rm -r $MNT2/lib/modules.bk

if [ "$ZEROROOT" = "Y" -o "$ZEROROOT" = "y" ]; then
    echo "Zero Root FS"
    dd if=/dev/zero of=$MNT2/zero bs=1M
    rm $MNT2/zero
fi

echo "wait 10 sec for mount"
sleep 10

umount $MNT
umount $MNT2
rmdir $MNT2

echo "DD 2048 * 1M"
dd bs=1M if=$DRIVE of=musicbox$IMGVERSION.img count=2048

echo "Copy Config back"
mount $PART1 $MNT
cp -r /tmp/config $MNT
rm -r /tmp/config

echo "wait 10 sec for mount"
sleep 10
umount $MNT
rmdir $MNT

#echo "cut image"
#dd if=/dev/zero of=musicbox$IMGVERSION.img bs=1 count=0 seek=2G

echo "zip image"
zip -9 musicbox$IMGVERSION.zip musicbox$IMGVERSION.img

echo "copy zip"
cp musicbox$IMGVERSION.zip /www/wouter/pimusicbox

#echo "Enter your Spotify Premium username: "
#read spotify_username
#echo "Enter your Spotify Premium password: "
#stty -echo
#read spotify_password ; echo
#stty echo

#sudo echo "SPOTIFY_USERNAME = '$spotify_username'" >> /root/.config/mopidy/settings.py
#sudo echo "SPOTIFY_PASSWORD = '$spotify_password'" >> /root/.config/mopidy/settings.py

