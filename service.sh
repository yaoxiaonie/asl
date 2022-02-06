#!/system/bin/sh

MODDIR=${0%/*}

rm -rf /data/adb/modules/asl/asl
# 需要启动的容器路径
ROOTFS=$(cat /data/asl/rootfs.config)
asl -c "/etc/init.d/ssh start" "$ROOTFS" >/dev/null 2>&1
