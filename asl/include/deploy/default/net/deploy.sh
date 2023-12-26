#!/system/bin/sh

# Copyright (C) 2021 MistyRain <1740621736@qq.com>

. $ASL_CLI/asl_print.sh
. $ASL_CLI/functions.sh
this_path=$(cd `dirname $0`;pwd)
container_name="$1"

asl_print "正在配置网络..."
temporarily_container_exec "$container_name" apt-get autoremove --purge -y systemd-resolved 2>/dev/null
rm $ASL_CONTAINER/$container_name/etc/resolv.conf
echo "nameserver 114.114.114.114
nameserver 114.114.115.115
nameserver 1.2.4.8
nameserver 240c::6666
nameserver 240c::6644" >$ASL_CONTAINER/$container_name/etc/resolv.conf
chmod 644 $ASL_CONTAINER/$container_name/etc/resolv.conf
