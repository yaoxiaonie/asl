#!/system/bin/sh

# Copyright (C) 2021 MistyRain <1740621736@qq.com>

. $ASL_CLI/asl_print.sh
. $ASL_CLI/functions.sh
this_path=$(cd `dirname $0`;pwd)
container_name="$1"

touch $ASL_CONTAINER/$container_name/root/.hushlogin

# 更换清华源
cp -afp $ASL_CONTAINER/$container_name/etc/apt/sources.list $ASL_CONTAINER/$container_name/etc/apt/sources.list.bak
sed -i "s|http://ports.ubuntu.com|http://mirrors.tuna.tsinghua.edu.cn|g" $ASL_CONTAINER/$container_name/etc/apt/sources.list
if [[ -d "$ASL_CONTAINER/$container_name/etc/debian_version" || -d "$ASL_CONTAINER/$container_name/etc/lsb-release" ]]; then
    echo "Debug::NoDropPrivs true;" >$ASL_CONTAINER/$container_name/etc/apt/apt.conf.d/00no-drop-privs
    touch $ASL_CONTAINER/$container_name/root/.hushlogin
fi

# 更新软件包
temporarily_container_exec $container_name apt update -y && apt upgrade -y
# 配置语言
temporarily_container_exec $container_name apt install -y locales-all
temporarily_container_exec $container_name apt install language-pack-zh-han* -y
mkdir -p $ASL_CONTAINER/$container_name/etc/default
echo "LANG="zh_CN.UTF-8"
LANGUAGE="zh_CN:zh"
LC_ALL="zh_CN.UTF-8"
">$ASL_CONTAINER/$container_name/etc/default/locale
temporarily_container_exec $container_name apt install -y neofetch
temporarily_container_exec $container_name neofetch