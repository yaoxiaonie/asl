#!/system/bin/sh

# Copyright (C) 2021 MistyRain <1740621736@qq.com>

. $ASL_CLI/asl_print.sh
. $ASL_CLI/functions.sh
this_path=$(cd `dirname $0`;pwd)
container_name="$1"

if [ "$CREATE_USER" = "true" ]; then
    asl_print "正在设置$USER_NAME用户（默认密码为：$USER_PASSWORD）..."
    temporarily_container_exec $container_name groupadd $USER_NAME
    temporarily_container_exec $container_name useradd -m -g $USER_NAME -s /bin/bash $USER_NAME
    temporarily_container_exec $container_name usermod -g $USER_NAME $USER_NAME
    echo $USER_NAME:$USER_PASSWORD | temporarily_container_exec $container_name chpasswd
    temporarily_container_exec $container_name chown $USER_NAME:$USER_NAME /home/$USER_NAME
elif [ "$CREATE_USER" = "false" ]; then
    asl_print "正在设置root用户（默认密码：root）..."
    echo "root:root" | temporarily_container_exec $container_name chpasswd
fi
