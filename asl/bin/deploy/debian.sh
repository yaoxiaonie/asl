#!/bin/bash

# Copyright (C) 2021 MistyRain <1740621736@qq.com>

function ASL_PRINT() {
    echo "「$(date '+%Y-%m-%d %H:%M:%S')」"$@""
}

# 网络配置
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
# 修复ping
ASL_PRINT "正在尝试修复ping..."
if [ -f "/etc/nsswitch.conf" ]; then
    sed -i 's/systemd//g' "/etc/nsswitch.conf"
fi
# 更换清华源
ASL_PRINT "正在更换清华源..."
cp "/etc/apt/sources.list" "/etc/apt/sources.list.bak"
sed -i "s|http://ports.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g" "/etc/apt/sources.list"
if [[ -d "/etc/debian_version" || -d "/etc/lsb-release" ]]; then
    echo "Debug::NoDropPrivs true;" >"/etc/apt/apt.conf.d/00no-drop-privs"
    touch "/root/.hushlogin"
fi
apt update -y && apt upgrade -y
# 设置用户
ASL_PRINT "正在设置root用户（默认密码：root）..."
echo "root:root" | chpasswd
# 更换地区
ASL_PRINT "正在配置中文环境..."
mkdir -p /etc/default
EXEC_ROOTFS "apt install language-pack-zh-han* -y"
cat > /etc/default/locale <<-LOCALE
LANG="zh_CN.UTF-8"
LANGUAGE="zh_CN:zh"
LC_NUMERIC="zh_CN"
LC_TIME="zh_CN"
LC_MONETARY="zh_CN"
LC_PAPER="zh_CN"
LC_NAME="zh_CN"
LC_ADDRESS="zh_CN"
LC_TELEPHONE="zh_CN"
LC_MEASUREMENT="zh_CN"
LC_IDENTIFICATION="zh_CN"
LC_ALL="zh_CN.UTF-8"
LOCALE
cat >> /etc/environment <<-ENV
LANG="zh_CN.UTF-8"
LANGUAGE="zh_CN:zh"
LC_NUMERIC="zh_CN"
LC_TIME="zh_CN"
LC_MONETARY="zh_CN"
LC_PAPER="zh_CN"
LC_NAME="zh_CN"
LC_ADDRESS="zh_CN"
LC_TELEPHONE="zh_CN"
LC_MEASUREMENT="zh_CN"
LC_IDENTIFICATION="zh_CN"
LC_ALL="zh_CN.UTF-8"
ENV
mkdir -p /etc/sysconfig
echo "LANG="zh_CN.utf8"" >/etc/sysconfig/i18n
echo "SYSFONT="latarcyrheb-sun16"" >>/etc/sysconfig/i18n
source /etc/sysconfig/i18n
echo "source /etc/sysconfig/i18n" >>/etc/bash.bashrc
apt install locales-all
echo "export LC_ALL=zh_CN.UTF-8" >>/etc/.profile
rm -rf "/etc/localtime"
cp -frp "/usr/share/zoneinfo/Asia/Shanghai" "/etc/localtime"
echo "Asia/Shanghai" >"/etc/timezone"
# 配置ssh
ASL_PRINT "正在配置ssh..."
apt install openssh-server -y
sed -i -E 's/#?Port .*/Port 4022/g' "/etc/ssh/sshd_config"
sed -i -E 's/#?PasswordAuthentication .*/PasswordAuthentication yes/g' "/etc/ssh/sshd_config"
sed -i -E 's/#?PermitRootLogin .*/PermitRootLogin yes/g' "/etc/ssh/sshd_config"
sed -i -E 's/#?AcceptEnv .*/AcceptEnv LANG/g' "/etc/ssh/sshd_config"
/etc/init.d/ssh stop
apt install neofetch -y
neofetch
echo >/root/.profile
ASL_PRINT "安装完成！"
