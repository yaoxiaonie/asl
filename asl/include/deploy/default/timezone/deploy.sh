#!/system/bin/sh

# Copyright (C) 2021 MistyRain <1740621736@qq.com>

. $ASL_CLI/asl_print.sh
. $ASL_CLI/functions.sh
this_path=$(cd `dirname $0`;pwd)
container_name="$1"

echo "Asia/Shanghai" >$ASL_CONTAINER/$container_name/etc/timezone
rm -rf $ASL_CONTAINER/$container_name/etc/localtime
ln -sf $ASL_CONTAINER/$container_name/usr/share/zoneinfo/Asia/Shanghai $ASL_CONTAINER/$container_name/etc/localtime
