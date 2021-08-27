#!/system/bin/sh

# Copyright (C) 2021 MistyRain <1740621736@qq.com>

MISSING_PARTITIONS="/dev /dev/pts /dev/net /sys /sys/virtual/socket /proc"
ROOTFS_PARTITIONS="/dev /dev/pts /proc"
ASL_VERSION="Dev-2.5"
TOOLKIT="/data/asl/bin"
HOME="/data/asl/rootfs"

function ASL_PRINT() {
    echo "「$(date '+%Y-%m-%d %H:%M:%S')」"$*""
}

function INSTALL_LINUX() {
    if [ -f "$1" ]; then
        TARGET_LINUX="$1"
        LINUX_TYPE="$2"
        ROOTFS="$HOME/$LINUX_TYPE"
        if [ ! -d "$ROOTFS" ]; then
            mkdir -p "$ROOTFS"
            ASL_PRINT "正在释放容器，请稍候..."
            $TOOLKIT/busybox tar -xJpf "$TARGET_LINUX" -C "$ROOTFS" --exclude='dev'
            ASL_PRINT "正在优化系统设置..."
            rm -rf "$ROOTFS/etc/mtab"
            cp "/proc/mounts" "$ROOTFS/etc/mtab"
            if ! $(grep -q "^127.0.0.1" "$ROOTFS/etc/hosts"); then
                echo '127.0.0.1 localhost' >> "$ROOTFS/etc/hosts"
                sed -i 's/LXC_NAME/LittleRain/g' "$ROOTFS/etc/hosts"
            fi
            rm -rf "$ROOTFS/etc/resolv.conf"
            echo "nameserver 8.8.8.8" >> "$ROOTFS/etc/resolv.conf"
            if [ -f "$ROOTFS/etc/nsswitch.conf" ]; then
                sed -i 's/systemd//g' "$ROOTFS/etc/nsswitch.conf"
            fi
            echo "inet:x:3003:root" >>$ROOTFS/etc/group
            echo "net_raw:x:3004:root" $ROOTFS/etc/group
            echo "LittleRain" > "$ROOTFS/etc/hostname"
            rm -rf "$ROOTFS/etc/localtime"
            cp -frp "$ROOTFS/usr/share/zoneinfo/Asia/Shanghai" "$ROOTFS/etc/localtime"
            echo "Asia/Shanghai" > "$ROOTFS/etc/timezone"
            cp "$ROOTFS/etc/apt/sources.list" "$ROOTFS/etc/apt/sources.list.bak"
            sed -i "s|http://ports.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g" "$ROOTFS/etc/apt/sources.list"
            if [ "$LINUX_TYPE" = "ubuntu" ]; then
                echo "Debug::NoDropPrivs true;" > "$ROOTFS/etc/apt/apt.conf.d/00no-drop-privs"
                touch "$ROOTFS/root/.hushlogin"
            fi
            EXEC_ROOTFS "echo "root:root" | chpasswd"
            EXEC_ROOTFS "apt update -y && apt upgrade -y && apt install openssh-server -y"
            sed -i -E 's/#?Port .*/Port 4022/g' "$ROOTFS/etc/ssh/sshd_config"
            sed -i -E 's/#?PasswordAuthentication .*/PasswordAuthentication yes/g' "$ROOTFS/etc/ssh/sshd_config"
            sed -i -E 's/#?PermitRootLogin .*/PermitRootLogin yes/g' "$ROOTFS/etc/ssh/sshd_config"
            sed -i -E 's/#?AcceptEnv .*/AcceptEnv LANG/g' "$ROOTFS/etc/ssh/sshd_config"
            EXEC_ROOTFS "/etc/init.d/ssh stop"
            sleep 1
            ASL_PRINT "安装完成！"
        else
            ASL_PRINT "已安装${LINUX_TYPE}，无需再次安装！"
        fi
    else
        LINUX_TYPE="$1"
        LINUX_VERSION="$2"
        ROOTFS="$HOME/$LINUX_TYPE"
        ASL_PRINT "正在解析下载链接..."
        ROOTFS_URL=$(curl -sL "https://mirrors.tuna.tsinghua.edu.cn/lxc-images/streams/v1/images.json" | awk -F '[,"}]' '{for(i=1;i<=NF;i++){print $i}}' | grep "images/$LINUX_TYPE/" | grep "$LINUX_VERSION" | grep "/arm64/default/" | grep "rootfs.tar.xz" | awk 'END {print}')
        ASL_PRINT "正在下载 ${LINUX_TYPE} ${LINUX_VERSION} ..."
        $TOOLKIT/axel -a -n "$(nproc --all)" -o "$HOME/${LINUX_TYPE}.tar.xz" "https://mirrors.tuna.tsinghua.edu.cn/lxc-images/$ROOTFS_URL" && ASL_PRINT "下载完成 !"
        if [ "$?" = "1" ]; then
            ASL_PRINT "下载失败 !"
            exit 1
        fi
        if [ -d "$ROOTFS" ]; then
            rm -rf "$ROOTFS"
        fi
        mkdir -p "$ROOTFS"
        ASL_PRINT "正在释放容器，请稍候..."
        $TOOLKIT/busybox tar -xJpf "$HOME/${LINUX_TYPE}.tar.xz" -C "$ROOTFS" --exclude='dev'
        ASL_PRINT "正在优化系统设置..."
        rm -rf "$ROOTFS/etc/mtab"
        cp "/proc/mounts" "$ROOTFS/etc/mtab"
        if ! $(grep -q "^127.0.0.1" "$ROOTFS/etc/hosts"); then
            echo '127.0.0.1 localhost' >> "$ROOTFS/etc/hosts"
            sed -i 's/LXC_NAME/LittleRain/g' "$ROOTFS/etc/hosts"
        fi
        rm -rf "$ROOTFS/etc/resolv.conf"
        echo "nameserver 8.8.8.8" >> "$ROOTFS/etc/resolv.conf"
        if [ -f "$ROOTFS/etc/nsswitch.conf" ]; then
            sed -i 's/systemd//g' "$ROOTFS/etc/nsswitch.conf"
        fi
        echo "inet:x:3003:root" >>$ROOTFS/etc/group
        echo "net_raw:x:3004:root" $ROOTFS/etc/group
        echo "LittleRain" > "$ROOTFS/etc/hostname"
        rm -rf "$ROOTFS/etc/localtime"
        cp -frp "$ROOTFS/usr/share/zoneinfo/Asia/Shanghai" "$ROOTFS/etc/localtime"
        echo "Asia/Shanghai" > "$ROOTFS/etc/timezone"
        cp "$ROOTFS/etc/apt/sources.list" "$ROOTFS/etc/apt/sources.list.bak"
        sed -i "s|http://ports.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g" "$ROOTFS/etc/apt/sources.list"
        if [ "$LINUX_TYPE" = "ubuntu" ]; then
            echo "Debug::NoDropPrivs true;" > "$ROOTFS/etc/apt/apt.conf.d/00no-drop-privs"
            touch "$ROOTFS/root/.hushlogin"
        fi
        EXEC_ROOTFS "echo "root:root" | chpasswd"
        EXEC_ROOTFS "apt update -y && apt upgrade -y && apt install openssh-server -y"
        sed -i -E 's/#?Port .*/Port 4022/g' "$ROOTFS/etc/ssh/sshd_config"
        sed -i -E 's/#?PasswordAuthentication .*/PasswordAuthentication yes/g' "$ROOTFS/etc/ssh/sshd_config"
        sed -i -E 's/#?PermitRootLogin .*/PermitRootLogin yes/g' "$ROOTFS/etc/ssh/sshd_config"
        sed -i -E 's/#?AcceptEnv .*/AcceptEnv LANG/g' "$ROOTFS/etc/ssh/sshd_config"
        EXEC_ROOTFS "/etc/init.d/ssh stop"
        sleep 1
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

function CREATE_PARTITIONS() {
    for TARGET_DIR in $MISSING_PARTITIONS; do
        if [ ! -d "$ROOTFS${TARGET_DIR}" ]; then
            case ${TARGET_DIR} in
            /dev)
                mkdir -p "$ROOTFS/dev"
                ASL_PRINT "创建 ${TARGET_DIR} 完成！"
                ;;
            /dev/pts)
                mkdir -p "$ROOTFS/dev/pts"
                ASL_PRINT "创建 ${TARGET_DIR} 完成！"
                ;;
            /dev/net)
                mkdir -p "$ROOTFS/dev/net"
                ASL_PRINT "创建 ${TARGET_DIR} 完成！"
                ;;
            /sys)
                mkdir -p "$ROOTFS/sys"
                ASL_PRINT "创建 ${TARGET_DIR} 完成！"
                ;;
            /sys/virtual/socket)
                mkdir -p "$ROOTFS/sys/virtual/socket"
                echo "# Dummy File" >"$ROOTFS/sys/virtual/socket/dotest"
                ASL_PRINT "创建 ${TARGET_DIR} 完成！"
                ;;
            /proc)
                mkdir -p "$ROOTFS/proc"
                ASL_PRINT "创建 ${TARGET_DIR} 完成！"
                ;;
            esac
        else
            ASL_PRINT "${TARGET_DIR} 已存在，本次跳过！"
        fi
    done
}

function MOUNT_PARTITIONS() {
    for TARGET_DIR in $ROOTFS_PARTITIONS; do
        if ! MOUNT_STATUS "$ROOTFS${TARGET_DIR}"; then
            case ${TARGET_DIR} in
            /dev)
                mount -o bind /dev "$ROOTFS/dev"
                ASL_PRINT "挂载 ${TARGET_DIR} 完成！"
                ;;
            /dev/pts)
                [ -d "/dev/pts" ] || mkdir -p /dev/pts
                mount -o rw,nosuid,noexec,gid=5,mode=620,ptmxmode=000 -t devpts devpts /dev/pts
                mount -t devpts devpts "$ROOTFS/dev/pts"
                ASL_PRINT "挂载 ${TARGET_DIR} 完成！"
                ;;
            /proc)
                [ -d "$ROOTFS/proc" ] || mkdir -p "$ROOTFS/proc"
                mount -t proc proc "$ROOTFS/proc"
                ASL_PRINT "挂载 ${TARGET_DIR} 完成！"
                ;;
            esac
        else
            ASL_PRINT "${TARGET_DIR} 已挂载，本次跳过。"
        fi
    done
}

function UMOUNT_PARTITIONS() {
    for TARGET_DIR in $ROOTFS_PARTITIONS; do
        $TOOLKIT/busybox umount -l "$ROOTFS${TARGET_DIR}" >/dev/null 2>&1
        ASL_PRINT "已取消挂载 ${TARGET_DIR}"
        sleep 1
    done
}

function EXEC_ROOTFS() {
    ASL_PRINT "正在检查容器分区..."
    CREATE_PARTITIONS
    MOUNT_PARTITIONS
    echo
    unset TMP TEMP TMPDIR LD_PRELOAD LD_DEBUG
    PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games:/usr/local/sbin:/sbin
    $TOOLKIT/unshare -R "$ROOTFS" bash -c "$*"
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
    EXEC_ROOTFS "bash --login"
    ;;
-d|--delete)
    ROOTFS="$2"
    UMOUNT_PARTITIONS
    ASL_PRINT "正在删除 ${ROOTFS}..."
    rm -rf "$HOME/$ROOTFS"
    ;;
-h|--help)
    USAGE
    ;;
*)
    ASL_PRINT "无事可做，试试加上-h或--help获取帮助？"
    exit 1
    ;;
esac
