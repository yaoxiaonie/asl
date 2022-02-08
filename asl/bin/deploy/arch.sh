#!/bin/bash

# Copyright (C) 2021 MistyRain <1740621736@qq.com>

function ASL_PRINT() {
    echo "「$(date '+%Y-%m-%d %H:%M:%S')」"$@""
}

# 配置网络
ASL_PRINT "正在配置网络..."
rm -rf "/etc/resolv.conf"
echo "nameserver 114.114.114.114" >>/etc/resolv.conf
echo "nameserver 114.114.115.115" >>/etc/resolv.conf
echo "nameserver 1.2.4.8" >>/etc/resolv.conf
echo "nameserver 240c::6666" >>/etc/resolv.conf
echo "nameserver 240c::6644" >>/etc/resolv.conf
echo "inet:x:3003:root" >>/etc/group
echo "net_raw:x:3004:root" >>/etc/group
# 修复挂载表
ASL_PRINT "正在修复挂载表..."
rm -rf "/etc/mtab"
cp "/proc/mounts" "/etc/mtab"
# 修改主机名
if ! $(grep -q "^127.0.0.1" "/etc/hosts"); then
    echo '127.0.0.1 localhost' >>"/etc/hosts"
    sed -i 's/LXC_NAME/LittleRain/g' "/etc/hosts"
fi
echo "LittleRain" >"/etc/hostname"
ASL_PRINT "正在更换清华源..."
# 配置清华源
sed -i -e '1i Server = http://mirrors.tuna.tsinghua.edu.cn/archlinuxarm/$arch/$repo' /etc/pacman.d/mirrorlist
# 配置ArchLinuxcn清华源
echo -e '[archlinuxcn]\nSigLevel = Optional TrustAll\nServer = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch' >> /etc/pacman.conf
pacman -Sy
pacman -Sq --noconfirm archlinuxcn-keyring
# 去除archlinuxcn警告
sed -i '/archlinuxcn/{n;d}' /etc/pacman.conf
# 配置中文环境
echo "正在配置中文环境..."
sed -i 's/#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen
echo -e "LANG=zh_CN.UTF-8\nLANGUAGE=zh_CN:zh:en_US" >/etc/locale.conf
locale-gen
# Arch自带了man，无需再次安装，仅安装中文语言包
pacman -Sq --noconfirm man-pages-zh_cn
# 配置国内时区
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
ASL_PRINT  "正在升级所有软件包..."
pacman -Syu --noconfirm
# pacman彩色输出
sed -i 's/#Color/Color/g' /etc/pacman.conf
# 配置ssh
ASL_PRINT "正在配置ssh..."
pacman -S openssh --noconfirm
sed -i -E 's/#?Port .*/Port 4022/g' "/etc/ssh/sshd_config"
sed -i -E 's/#?PasswordAuthentication .*/PasswordAuthentication yes/g' "/etc/ssh/sshd_config"
sed -i -E 's/#?PermitRootLogin .*/PermitRootLogin yes/g' "/etc/ssh/sshd_config"
sed -i -E 's/#?AcceptEnv .*/AcceptEnv LANG/g' "/etc/ssh/sshd_config"
# 设置用户
echo "正在设置root用户（默认密码：root）..."
echo "root:root" | chpasswd
pacman -S neofetch --noconfirm
neofetch
echo >/root/.profile
ASL_PRINT "安装完成！"
