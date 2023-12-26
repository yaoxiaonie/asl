#!/system/bin/sh
# Please don't hardcode /magisk/modname/... ; instead, please use $MODDIR/...
# This will make your scripts compatible even if Magisk change its mount point in the future
MODDIR=$(cd `dirname $0`;pwd)
ASL_PROJECT_DIR="/data/asl"

# This script will be executed in late_start service mode
# More info in the main Magisk thread

# 等待设备完成引导
while [ "$(getprop sys.boot_completed)" != "1" ] && [ $COUNT -lt 3]; do
    sleep 10
    COUNT=$((COUNT+1))
done

container_names=$(cat $ASL_PROJECT_DIR/auto-startup.txt)
if [ -n "$container_names" ]; then
    uptime -s >$MODDIR/ssh.log
    for container_name in $container_names; do
        echo "" >>$MODDIR/ssh.log
        echo "正在启动容器：${container_name}..."
        asl -s "$container_name" >>$MODDIR/ssh.log
    done
fi
