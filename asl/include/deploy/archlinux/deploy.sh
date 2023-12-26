#!/system/bin/sh

# Copyright (C) 2021 MistyRain <1740621736@qq.com>

. $ASL_CLI/asl_print.sh
. $ASL_CLI/functions.sh
this_path=$(cd `dirname $0`;pwd)
container_name="$1"

asl_print "正在更换清华源..."
# 配置清华源
sed -i -e '1i Server = http://mirrors.tuna.tsinghua.edu.cn/archlinuxarm/$arch/$repo' $ASL_CONTAINER/$container_name/etc/pacman.d/mirrorlist
# 配置ArchLinuxcn清华源
echo -e '[archlinuxcn]\nSigLevel = Optional TrustAll\nServer = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch' >>$ASL_CONTAINER/$container_name/etc/pacman.conf
temporarily_container_exec $container_name pacman -Sy
temporarily_container_exec $container_name pacman -Sq --noconfirm archlinuxcn-keyring
# 去除archlinuxcn警告
sed -i '/archlinuxcn/{n;d}' $ASL_CONTAINER/$container_name/etc/pacman.conf
# 配置中文环境
asl_print "正在配置中文环境..."
sed -i 's/#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' $ASL_CONTAINER/$container_name/etc/locale.gen
echo -e "LANG=zh_CN.UTF-8\nLANGUAGE=zh_CN:zh:en_US" >$ASL_CONTAINER/$container_name/etc/locale.conf
locale-gen
# Arch自带了man，无需再次安装，仅安装中文语言包
temporarily_container_exec $container_name pacman -Sq --noconfirm man-pages-zh_cn
asl_print  "正在升级所有软件包..."
temporarily_container_exec $container_name pacman -Syu --noconfirm
# pacman彩色输出
sed -i 's/#Color/Color/g' $ASL_CONTAINER/$container_name/etc/pacman.conf

temporarily_container_exec $container_name pacman -S neofetch --noconfirm
temporarily_container_exec $container_name neofetch
