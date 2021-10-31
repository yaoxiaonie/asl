#!/system/bin/sh

MODDIR=${0%/*}

rm -rf /data/adb/modules/asl/asl
chmod 0755 /data/adb/modules/asl/system/xbin/asl
# 需要启动的容器路径
ROOTFS=$(cat /data/asl/rootfs.config)
asl -c "/etc/init.d/ssh start" "$ROOTFS" >/dev/null 2>&1
