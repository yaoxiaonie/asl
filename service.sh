#!/system/bin/sh

MODDIR=${0%/*}

rm -rf /data/adb/modules/asl/asl
chmod 0755 /data/adb/modules/asl/system/xbin/asl
ROOTFS=$(ls /data/asl/rootfs)
asl -c "/etc/init.d/ssh start" "/data/asl/rootfs/$ROOTFS" >/dev/null 2>&1
