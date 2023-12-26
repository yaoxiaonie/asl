#!/system/bin/sh

# Copyright (C) 2021 MistyRain <1740621736@qq.com>

. $ASL_CLI/asl_print.sh
. $ASL_CLI/functions.sh
this_path=$(cd `dirname $0`;pwd)
container_name="$1"
container_type=""

function configure_debian() {
    temporarily_container_exec $container_name apt install openssh-server -y
    sed -i -E 's/#?Port .*/Port 4022/g' $ASL_CONTAINER/$container_name/etc/ssh/sshd_config
    sed -i -E 's/#?PasswordAuthentication .*/PasswordAuthentication yes/g' $ASL_CONTAINER/$container_name/etc/ssh/sshd_config
    sed -i -E 's/#?PermitRootLogin .*/PermitRootLogin yes/g' $ASL_CONTAINER/$container_name/etc/ssh/sshd_config
    sed -i -E 's/#?AcceptEnv .*/AcceptEnv LANG/g' $ASL_CONTAINER/$container_name/etc/ssh/sshd_config
    temporarily_container_exec $container_name /etc/init.d/ssh stop
}

function configure_arch() {
    pacman -S openssh --noconfirm
    sed -i -E 's/#?Port .*/Port 4022/g' $ASL_CONTAINER/$container_name/etc/ssh/sshd_config
    sed -i -E 's/#?PasswordAuthentication .*/PasswordAuthentication yes/g' $ASL_CONTAINER/$container_name/etc/ssh/sshd_config
    sed -i -E 's/#?PermitRootLogin .*/PermitRootLogin yes/g' $ASL_CONTAINER/$container_name/etc/ssh/sshd_config
    sed -i -E 's/#?AcceptEnv .*/AcceptEnv LANG/g' $ASL_CONTAINER/$container_name/etc/ssh/sshd_config
    temporarily_container_exec $container_name /etc/init.d/ssh stop
}

if [ -f $ASL_CONTAINER/$container_name/etc/lsb-release ]; then
    source $ASL_CONTAINER/$container_name/etc/lsb-release
    case "$DISTRIB_ID" in
        "Ubuntu")
            container_type="ubuntu"
            ;;
    esac
elif [ -f $ASL_CONTAINER/$container_name/etc/centos-release ]; then
    container_type="centos"
elif [ -f $ASL_CONTAINER/$container_name/etc/fedora-release ]; then
    container_type="Fedora"
elif [ -f $ASL_CONTAINER/$container_name/etc/debian_version ]; then
    container_type="debian"
elif [ -f $ASL_CONTAINER/$container_name/etc/arch-release ]; then
    container_type="archlinux"
elif [ -f $ASL_CONTAINER/$container_name/etc/os-release ]; then
    source $ASL_CONTAINER/$container_name/etc/os-release
    case "$ID" in
        "opensuse")
            container_type="opensuse"
            ;;
        "manjaro")
            container_type="manjaro"
            ;;
    esac
fi

asl_print "正在配置ssh..."
case "$container_type" in
    "ubuntu")
        configure_debian
        ;;
    "archlinux")
        configure_debian
        ;;
esac

