#!/system/bin/sh

# Copyright (C) 2021 MistyRain <1740621736@qq.com>

function ASL_PRINT() {
    echo "「$(date '+%Y-%m-%d %H:%M:%S')」"$@""
}

function INSTALL_LINUX() {
    if [ "$INSTALL_LINUX_LOCAL" = "true" ]; then
        if [ -f "$1" ]; then
            TARGET_LINUX="$1"
            LINUX_NAME="$2"
            ROOTFS="$ASL_HOME/$LINUX_NAME"
            if [ ! -d "$ROOTFS" ]; then
                mkdir -p "$ROOTFS"
                ASL_PRINT "正在释放容器，请稍候..."
                if [ "$ASL_MODE" = "unshare" ]; then
                    pv "$TARGET_LINUX" | tar -xJpf -C "$ROOTFS" --exclude='dev'
                else
                    pv "$TARGET_LINUX" | $PROOT --link2symlink tar -xJp  -C "$ROOTFS" --exclude='dev'
                fi
                if [ "$?" = "1" ]; then
                    ASL_PRINT "释放失败，可能文件已损坏！"
                    exit 1
                fi
                ASL_PRINT "正在优化系统设置..."
                if [[ "$(awk -F= '$1 == "ID_LIKE" {print $2}' $ROOTFS/etc/os-release)" = "arch" ]]; then
                    cat $ASL_TOOLKIT/deploy/arch.sh >$ROOTFS/root/.profile
                    EXEC_ROOTFS "bash --login"
                else
                    cat $ASL_TOOLKIT/deploy/debian.sh >$ROOTFS/root/.profile
                    EXEC_ROOTFS "bash --login"
                fi
            else
                ASL_PRINT "已存在${LINUX_NAME}，无法再进行安装！"
                exit 1
            fi
        else
            ASL_PRINT "找不到文件！"
            exit 1
        fi
    else
        LINUX_TYPE="$1"
        LINUX_VERSION="$2"
        ROOTFS="$ASL_HOME/${LINUX_TYPE}"
        if [ -d "$ROOTFS" ]; then
            ASL_PRINT "容器已存在，请删除容器后重试！"
            exit 1
        fi
        ASL_PRINT "正在解析下载链接..."
        ROOTFS_URL=$(curl -sL "https://mirrors.tuna.tsinghua.edu.cn/lxc-images/streams/v1/images.json" | awk -F '[,"}]' '{for(i=1;i<=NF;i++){print $i}}' | grep "images/$LINUX_TYPE/" | grep "$LINUX_VERSION" | grep "/arm64/default/" | grep "rootfs.tar.xz" | awk 'END {print}')
        ASL_PRINT "正在下载${LINUX_TYPE} ${LINUX_VERSION} ..."
        axel -a -n "$(nproc --all)" -o "$ASL_TMP/rootfs.tar.xz" "https://mirrors.tuna.tsinghua.edu.cn/lxc-images/$ROOTFS_URL" && ASL_PRINT "下载完成 !"
        if [ "$?" = "1" ]; then
            ASL_PRINT "下载失败 !"
            exit 1
        elif [ ! -f "$ASL_TMP/rootfs.tar.xz" ]; then
            ASL_PRINT "找不到下载的文件 !"
            exit 1
        fi
        mkdir -p "$ROOTFS"
        ASL_PRINT "正在释放容器，请稍候..."
        if [ "$ASL_MODE" = "unshare" ]; then
            pv "$ASL_TMP/rootfs.tar.xz" | tar -xJp -C "$ROOTFS" --exclude='dev'
        else
            pv "$ASL_TMP/rootfs.tar.xz" | $PROOT --link2symlink tar -xJp -C "$ROOTFS" --exclude='dev'
        fi
        if [ "$?" = "1" ]; then
            ASL_PRINT "释放失败，可能文件已损坏！"
            exit 1
        fi
        rm -rf "$ASL_TMP/rootfs.tar.xz"
        ASL_PRINT "正在优化系统设置..."
        if [[ "$(awk -F= '$1 == "ID_LIKE" {print $2}' $ROOTFS/etc/os-release)" = "arch" ]]; then
            cat $ASL_TOOLKIT/deploy/arch.sh >$ROOTFS/root/.profile
            EXEC_ROOTFS "bash --login"
        else
            cat $ASL_TOOLKIT/deploy/debian.sh >$ROOTFS/root/.profile
            EXEC_ROOTFS "bash --login"
        fi
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
    if [ "$LOG_RETURE" = "true" ]; then
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
    else
        for TARGET_DIR in $MISSING_PARTITIONS; do
            if [ ! -d "$ROOTFS${TARGET_DIR}" ]; then
                case ${TARGET_DIR} in
                /dev)
                    mkdir -p "$ROOTFS/dev"
                    ;;
                /dev/pts)
                    mkdir -p "$ROOTFS/dev/pts"
                    ;;
                /dev/net)
                    mkdir -p "$ROOTFS/dev/net"
                    ;;
                /sys)
                    mkdir -p "$ROOTFS/sys"
                    ;;
                /sys/virtual/socket)
                    mkdir -p "$ROOTFS/sys/virtual/socket"
                    echo "# Dummy File" >"$ROOTFS/sys/virtual/socket/dotest"
                    ;;
                /proc)
                    mkdir -p "$ROOTFS/proc"
                    ;;
                esac
            fi
        done
    fi
}

function MOUNT_PARTITIONS() {
    if [ "$LOG_RETURE" = "true" ]; then
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
    else
        for TARGET_DIR in $ROOTFS_PARTITIONS; do
            if ! MOUNT_STATUS "$ROOTFS${TARGET_DIR}"; then
                case ${TARGET_DIR} in
                /dev)
                    mount -o bind /dev "$ROOTFS/dev"
                    ;;
                /dev/pts)
                    [ -d "/dev/pts" ] || mkdir -p /dev/pts
                    mount -o rw,nosuid,noexec,gid=5,mode=620,ptmxmode=000 -t devpts devpts /dev/pts
                    mount -t devpts devpts "$ROOTFS/dev/pts"
                    ;;
                /proc)
                    [ -d "$ROOTFS/proc" ] || mkdir -p "$ROOTFS/proc"
                    mount -t proc proc "$ROOTFS/proc"
                    ;;
                esac
            fi
        done
    fi
}

function UMOUNT_PARTITIONS() {
    if [ "$LOG_RETURE" = "true" ]; then
        for TARGET_DIR in $ROOTFS_PARTITIONS; do
            umount -l "$ROOTFS${TARGET_DIR}" >/dev/null 2>&1
            ASL_PRINT "已取消挂载 ${TARGET_DIR}"
            sleep 1
        done
    else
        for TARGET_DIR in $ROOTFS_PARTITIONS; do
            umount -l "$ROOTFS${TARGET_DIR}" >/dev/null 2>&1
            sleep 1
        done
    fi
}

function EXEC_ROOTFS() {
    if [ "$ASL_MODE" = "unshare" ]; then
        ASL_PRINT "正在检查容器分区..."
        CREATE_PARTITIONS
        MOUNT_PARTITIONS
        echo
        unset TMP TEMP TMPDIR LD_PRELOAD LD_DEBUG
        PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games:/usr/local/sbin:/sbin
        $UNSHARE -R "$ROOTFS" bash -c "$@"
    else
        unset LD_PRELOAD
        $PROOT --link2symlink -0 -r $ROOTFS -b /dev -b /proc -b $ROOTFS/root:/dev/shm -w /root /usr/bin/env -i HOME=/root PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games TERM=$TERM LANG=zh_CN.UTF-8 bash -c "$@"
    fi
}

function USAGE() {
    echo "使用方法：$0 <参数1> <参数2> <参数3> <参数4>"
    echo -e "\t -i|--install：安装来自清华源的Linux容器「参数2为容器类型，参数3为容器版本代号」"
    echo -e "\t    当参数4为 [ --local ] 时，使用本地文件安装「参数2为文件位置，参数3为自定义的容器名」"
    echo -e "\t -c|--command：在指定容器内部执行指定命令「参数2为命令，参数3为自定义的容器名」"
    echo -e "\t -l|--login：登录至指定容器内部「参数2为容器位置」"
    echo -e "\t -d|--delete：删除指定容器「参数2为容器位置」"
    echo -e "\t -v|--version：展示ASL程序版本"
}

# 挂载分区设置
MISSING_PARTITIONS="/dev /dev/pts /dev/net /sys /sys/virtual/socket /proc"
ROOTFS_PARTITIONS="/dev /dev/pts /proc"

ASL_PROJECT=$(cd `dirname $0`;cd ..;pwd)
if [ -f "$ASL_PROJECT/bin/asl.conf" ]; then
    cat $ASL_PROJECT/bin/asl.conf | sed '/^#/d' | sed '/^$/d' | sed 's/: /=/g' | sed 's/^/export /g' >$ASL_PROJECT/bin/asl_opinion
    source $ASL_PROJECT/bin/asl_opinion
    rm -rf $ASL_PROJECT/bin/asl_opinion
else
    echo "找不到asl.conf，请确保本程序资源完整！"
    exit 1
fi

if [ ! -d "$ASL_TOOLKIT/deploy" ]; then
    echo "找不到deploy文件夹，请确保本程序资源完整！"
    exit 1
fi

if [ "$#" -gt "0" ]; then
    DIRECTION="$1"
    shift
fi

case "$DIRECTION" in
-i | --install)
    if [ "$3" = "--local" ]; then
        INSTALL_LINUX_LOCAL="true"
    fi
    INSTALL_LINUX "$1" "$2"
    ;;
-c | --command)
    ROOTFS="$ASL_HOME/$2"
    EXEC_ROOTFS "$1"
    ;;
-l | --login)
    ROOTFS="$ASL_HOME/$1"
    EXEC_ROOTFS "bash --login"
    ;;
-d | --delete)
    ROOTFS="$ASL_HOME/$1"
    if [ "$ASL_MODE" = "unshare" ]; then
        UMOUNT_PARTITIONS
    fi
    ASL_PRINT "正在删除${1}..."
    chmod -R 777 $ROOTFS
    rm -rf "$ROOTFS"
    ASL_PRINT "删除完成！"
    ;;
-h | --help)
    USAGE
    ;;
-v | --version)
    echo "ASL Version: $ASL_VERSION"
    echo "Author: MistyRain"
    echo "Repo Url: https://github.com/yaoxiaonie/asl"
    ;;
*)
    ASL_PRINT "无事可做，试试加上-h或--help获取帮助？"
    exit 1
    ;;
esac
