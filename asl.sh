#!/bin/bash

# Copyright (C) 2021 MistyRain <1740621736@qq.com>

ROOTFS_PARTITIONS="/ /dev /proc /sys /dev/shm /dev/pts"
ANDROID_PARTITIONS="/dev/fd /dev/stdin /dev/stout /dev/sterr /dev/tty0 /dev/net/tun"
ASL_VERSION="Dev-2.0"

function ASL_PRINT() {
    echo "「$(date '+%Y-%m-%d %H:%M:%S')」"$*""
}

function INSTALL_LINUX() {
    if [ -f "$1" ]; then
        TARGET_LINUX="$1"
        LINUX_TYPE="$2"
        if [ ! -d "$HOME/$LINUX_TYPE" ]; then
            mkdir -p "$HOME/$LINUX_TYPE"
            ASL_PRINT "正在释放容器，请稍候..."
            tar -xJpf "$THISPATH/$TARGET_LINUX" -C "$HOME/$LINUX_TYPE" --exclude='dev'
            ASL_PRINT "正在优化系统设置..."
            echo "127.0.0.1 localhost" > "$HOME/$LINUX_TYPE/etc/hosts"
            rm -rf "$HOME/$LINUX_TYPE/etc/resolv.conf"
            echo "nameserver 114.114.114.114" > "$HOME/$LINUX_TYPE/etc/resolv.conf"
            echo "nameserver 8.8.4.4" >> "$HOME/$LINUX_TYPE/etc/resolv.conf"
            echo "export  TZ='Asia/Shanghai'" >> "$HOME/$LINUX_TYPE/root/.bashrc"
            echo "LittleRain" > "$HOME/$LINUX_TYPE/etc/hostname"
            cp -frp "$HOME/$LINUX_TYPE/etc/apt/sources.list" "$HOME/$LINUX_TYPE/etc/apt/sources.list.bak"
            sed -i "s|http://ports.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g" "$HOME/$LINUX_TYPE/etc/apt/sources.list"
            if [ "$LINUX_TYPE" = "ubuntu" ]; then
                touch "$HOME/$LINUX_TYPE/root/.hushlogin"
            fi
            sleep 1
            ASL_PRINT "安装完成！"
        else
            ASL_PRINT "已安装${LINUX_TYPE}，无需再次安装！"
        fi
    else
        LINUX_TYPE="$1"
        LINUX_VERSION="$2"
        ASL_PRINT "正在解析下载链接..."
        ROOTFS_URL=$(curl -sL "https://mirrors.tuna.tsinghua.edu.cn/lxc-images/streams/v1/images.json" | awk -F '[,"}]' '{for(i=1;i<=NF;i++){print $i}}' | grep "images/$LINUX_TYPE/" | grep "$LINUX_VERSION" | grep "/arm64/default/" | grep "rootfs.tar.xz" | awk 'END {print}')
        ASL_PRINT "正在下载 ${LINUX_TYPE} ${LINUX_VERSION} ..."
        axel -a -n "$(nproc --all)" -o "$HOME/${LINUX_TYPE}.tar.xz" "https://mirrors.tuna.tsinghua.edu.cn/lxc-images/$ROOTFS_URL" && ASL_PRINT "下载完成 !"
        if [ "$?" = "1" ]; then
            ASL_PRINT "下载失败 !"
            exit 1
        fi
        if [ -d "$HOME/$LINUX_TYPE" ]; then
            rm -rf "$HOME/$LINUX_TYPE"
        fi
        mkdir -p "$HOME/$LINUX_TYPE"
        ASL_PRINT "正在释放容器，请稍候..."
        tar -xJpf "$HOME/${LINUX_TYPE}.tar.xz" -C "$HOME/$LINUX_TYPE" --exclude='dev' --exclude='etc/rc.d' --exclude='usr/lib64/pm-utils'
        ASL_PRINT "正在优化系统设置..."
        echo "127.0.0.1 localhost" > "$HOME/$LINUX_TYPE/etc/hosts"
        rm -rf "$HOME/$LINUX_TYPE/etc/resolv.conf"
        echo "nameserver 114.114.114.114" > "$HOME/$LINUX_TYPE/etc/resolv.conf"
        echo "nameserver 8.8.4.4" >> "$HOME/$LINUX_TYPE/etc/resolv.conf"
        echo "export  TZ='Asia/Shanghai'" >> "$HOME/$LINUX_TYPE/root/.bashrc"
        echo "LittleRain" > "$HOME/$LINUX_TYPE/etc/hostname"
        cp -frp "$HOME/$LINUX_TYPE/etc/apt/sources.list" "$HOME/$LINUX_TYPE/etc/apt/sources.list.bak"
        sed -i "s|http://ports.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g" "$HOME/$LINUX_TYPE/etc/apt/sources.list"
        if [ "$LINUX_TYPE" = "ubuntu" ]; then
            touch "$HOME/$LINUX_TYPE/root/.hushlogin"
        fi
        rm -rf "$HOME/${LINUX_TYPE}.tar.xz"
        sleep 1
        echo "安装完成！"
    fi
}

function MOUNT_STATUS() {
    MOUNT_VAR="$1"
    if grep -q " ${MOUNT_VAR%/} " /proc/mounts >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

function MOUNT_PARTITIONS() {
    for TARGET_DIR in $ROOTFS_PARTITIONS; do
        if ! MOUNT_STATUS "$ROOTFS${TARGET_DIR}"; then
            case ${TARGET_DIR} in
            /)
                mount --rbind $ROOTFS $ROOTFS/
                mount -o remount,exec,suid,dev "$ROOTFS"
                ASL_PRINT "挂载 ${TARGET_DIR} 完成！"
                ;;
            /dev)
                [ -d "$ROOTFS/dev" ] || mkdir -p "$ROOTFS/dev"
                mount -o bind /dev "$ROOTFS/dev"
                ASL_PRINT "挂载 ${TARGET_DIR} 完成！"
                ;;
            /proc)
                [ -d "$ROOTFS/proc" ] || mkdir -p "$ROOTFS/proc"
                mount -t proc proc "$ROOTFS/proc"
                ASL_PRINT "挂载 ${TARGET_DIR} 完成！"
                ;;
            /sys)
                [ -d "$ROOTFS/sys" ] || mkdir -p "$ROOTFS/sys"
                mount -t sysfs sys "$ROOTFS/sys"
                ASL_PRINT "挂载 ${TARGET_DIR} 完成！"
                ;;
            /dev/shm)
                [ -d "/dev/shm" ] || mkdir -p /dev/shm
                mount -o rw,nosuid,nodev,mode=1777 -t tmpfs tmpfs /dev/shm
                [ -d "$ROOTFS/dev/shm" ] || mkdir -p $ROOTFS/dev/shm
                mount -o bind /dev/shm "$ROOTFS/dev/shm"
                ASL_PRINT "挂载 ${TARGET_DIR} 完成！"
                ;;
            /dev/pts)
                [ -d "/dev/pts" ] || mkdir -p /dev/pts
                mount -o rw,nosuid,noexec,gid=5,mode=620,ptmxmode=000 -t devpts devpts /dev/pts
                [ -d "$ROOTFS/dev/pts" ] || mkdir -p $ROOTFS/dev/pts
                mount -o bind /dev/pts "$ROOTFS/dev/pts"
                ASL_PRINT "挂载 ${TARGET_DIR} 完成！"
                ;;
            esac
        else
            ASL_PRINT "${TARGET_DIR} 已挂载，本次跳过。"
        fi
    done
}

function CONNECT_PARTITIONS() {
    for TARGET_DIR in $ANDROID_PARTITIONS; do
        if [ ! -e ${TARGET_DIR} ] && [ ! -h ${TARGET_DIR} ]; then
            case ${TARGET_DIR} in
            /dev/fd)
                ln -s /proc/self/fd ${TARGET_DIR} >/dev/null 2>&1
                ASL_PRINT "创建 ${TARGET_DIR} 完成！"
                ;;
            /dev/stdin)
                ln -s /proc/self/fd/0 ${TARGET_DIR} >/dev/null 2>&1
                ASL_PRINT "创建 ${TARGET_DIR} 完成！"
                ;;
            /dev/stdout)
                ln -s /proc/self/fd/1 ${TARGET_DIR} >/dev/null 2>&1
                ASL_PRINT "创建 ${TARGET_DIR} 完成！"
                ;;
            /dev/stderr)
                ln -s /proc/self/fd/2 ${TARGET_DIR} >/dev/null 2>&1
                ASL_PRINT "创建 ${TARGET_DIR} 完成！"
                ;;
            /dev/tty0)
                ln -s /dev/null ${TARGET_DIR} >/dev/null 2>&1
                ASL_PRINT "创建 ${TARGET_DIR} 完成！"
                ;;
            /dev/net/tun)
                [ -d "/dev/net" ] || mkdir -p /dev/net
                mknod /dev/net/tun c 10 200
                ASL_PRINT "创建 ${TARGET_DIR} 完成！"
                ;;
            esac
        else
            ASL_PRINT "${TARGET_DIR} 已存在，本次跳过！"
        fi
    done
}

function UMOUNT_PARTITIONS() {
    for TARGET_DIR in $ROOTFS_PARTITIONS; do
        umount -l "$ROOTFS${TARGET_DIR}" >/dev/null 2>&1
        ASL_PRINT "已取消挂载 ${TARGET_DIR}"
        sleep 1
    done
}

function EXEC_ROOTFS() {
    ASL_PRINT "正在检查容器分区..."
    MOUNT_PARTITIONS
    CONNECT_PARTITIONS
    echo
    unset TMP TEMP TMPDIR LD_PRELOAD LD_DEBUG
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    $TOOLKIT/bin/unshare -R "$ROOTFS" /bin/bash -c "$*"
}

function USAGE() {
    echo "使用方法：$0 <参数1> <参数2> <参数3>"
    echo -e "\t -i|--install：安装来自清华源的Linux容器，也可指定本地的tar.xz安装「参数2为容器类型，参数3为容器版本代号」"
    echo -e "\t -c|--command：在指定容器内部执行指定命令「参数2为命令，参数3为容器位置」"
    echo -e "\t -l|--login：登录至指定容器内部「参数2为容器位置」"
    echo -e "\t -d|--delete：删除指定容器「参数2为容器位置」"
}

case "$1" in
-i|--install)
    INSTALL_LINUX "$2" "$3"
    ;;
-c|--command)
    ROOTFS="$3"
    EXEC_ROOTFS "$2"
    ;;
-l|--login)
    ROOTFS="$2"
    EXEC_ROOTFS "/bin/bash --login"
    ;;
-d|--delete)
    ROOTFS="$2"
    UMOUNT_PARTITIONS
    ASL_PRINT "正在删除${ROOTFS}..."
    rm -rf "$ROOTFS"
    ;;
-h|--help)
    USAGE
    ;;
*)
    ASL_PRINT "无事可做，试试加上-h或--help获取帮助？"
    exit 1
    ;;
esac
