#!/system/bin/sh

# Copyright (C) 2021 MistyRain <1740621736@qq.com>

. $ASL_CLI/asl_print.sh
. $ASL_CLI/extract_rootfs.sh

function download_rootfs_package() {
    local rootfs_type="$1"
    local rootfs_version="$2"
    local rootfs_config="{\"rootfs_type\": \"$rootfs_type\", \"rootfs_version\": \"$rootfs_version\"}"
    local rootfs_url=$(curl -skl "https://mirrors.tuna.tsinghua.edu.cn/lxc-images/streams/v1/images.json" | jq . | jq -r --argjson vars "$rootfs_config" '.products.[$vars.rootfs_type+":"+$vars.rootfs_version+":arm64:default"].versions | to_entries | max_by(.value.items."root.tar.xz".path) | .value.items."root.tar.xz".path')
    local rootfs_sha256=$(curl -skl "https://mirrors.tuna.tsinghua.edu.cn/lxc-images/streams/v1/images.json" | jq . | jq -r --arg rootfs_type "$rootfs_type" --arg rootfs_version "$rootfs_version" --arg path "$rootfs_url" '.products | to_entries[] | select(.key | contains($rootfs_type) and contains($rootfs_version)) | .value.versions | to_entries[] | select(.value.items."root.tar.xz".path == $path) | .value.items."root.tar.xz".sha256')
    local rootfs_file="$ASL_TMP/rootfs.tar.xz"
    asl_print "ROOTFS URL：https://mirrors.tuna.tsinghua.edu.cn/lxc-images/$rootfs_url"
    asl_print "ROOTFS SHA256：$rootfs_sha256"
    aria2c --check-certificate=false -s "$(nproc --all)" -d "$ASL_TMP" -o "rootfs.tar.xz" "https://mirrors.tuna.tsinghua.edu.cn/lxc-images/$rootfs_url" && asl_print "下载完成 !"
    if [ "$(sha256sum $rootfs_file | awk '{print $1}')" = "$rootfs_sha256" ]; then
        asl_print "rootfs.tar.xz文件SHA256校验成功！"
    else
        asl_print "rootfs.tar.xz文件SHA256校验失败！"
        exit 1
    fi
}

function install_rootfs_package_local() {
    local rootfs_type="$1"
    local container_name="$2"
    local rootfs_file="$3"
    mkdir -p "$ASL_CONTAINER/$container_name"
    asl_print "正在释放容器，请稍候..."
    if [ "$ASL_MODE" = "unshare" ]; then
        extract_rootfs "$rootfs_file" "$ASL_CONTAINER/$container_name"
    else
        pv "$rootfs_file" | $PROOT --link2symlink tar -xJp -C "$ASL_CONTAINER/$container_name" --exclude='dev'
    fi
    deploy_container "$rootfs_type" "$container_name"
}

function install_rootfs_package_online() {
    local rootfs_type="$1"
    local rootfs_version="$2"
    local container_name="$3"
    local rootfs_file="$ASL_TMP/rootfs.tar.xz"
    rm -f $rootfs_file
    download_rootfs_package "$rootfs_type" "$rootfs_version"
    install_rootfs_package_local "$rootfs_type" "$container_name" "$rootfs_file"
}

function deploy_container() {
    local rootfs_type="$1"
    local container_name="$2"
    local IFS=" "
    for deployment_before in $DEPLOYMENT_SEQUENCE_BEFORE; do
        if [ -f "$ASL_INCLUDE/deploy/default/$deployment_before/deploy.sh" ]; then
            asl_print "当前栏目：$deployment_before"
            $ASL_INCLUDE/deploy/default/$deployment_before/deploy.sh "$container_name"
        fi
    done
    $ASL_INCLUDE/deploy/$rootfs_type/deploy.sh "$container_name"
    for deployment_later in $DEPLOYMENT_SEQUENCE_LATER; do
        if [ -f "$ASL_INCLUDE/deploy/default/$deployment_before/deploy.sh" ]; then
            asl_print "当前栏目：$deployment_later"
            $ASL_INCLUDE/deploy/default/$deployment_later/deploy.sh "$container_name"
        fi
    done
}


function is_mounted() {
    local mount_point="$1"
    if grep -q " ${mount_point%/} " /proc/mounts >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

function mount_partitions() {
    local container_name="$1"
    local partition
    local IFS=" "
    if [ ! -f "$ASL_STATUS/${container_name}_status" ]; then
        echo "CONTAINER_MOUNT_STATUS=no" >$ASL_STATUS/${container_name}_status
        echo "SYSTEM_UPTIME=$(date -d "$(uptime -s)" +%s)" >>$ASL_STATUS/${container_name}_status
    fi
    local mount_status=$(grep 'CONTAINER_MOUNT_STATUS' $ASL_STATUS/${container_name}_status | cut -d '=' -f 2)
    local system_uptime=$(grep 'SYSTEM_UPTIME' $ASL_STATUS/${container_name}_status | cut -d '=' -f 2)
    local absolute_value=$(expr $system_uptime - $(date -d "$(uptime -s)" +%s))
    if [ "${absolute_value#-}" -gt "2" ] || [ "$mount_status" != "yes" ]; then
        for partition in $ASL_PARTITIONS; do
            case "$partition" in
                "/")
                    if ! is_mounted "$ASL_CONTAINER/$container_name"; then
                        [ -d "$ASL_CONTAINER/$container_name" ] && mount --rbind "$ASL_CONTAINER/$container_name" "$ASL_CONTAINER/$container_name/" && mount -o remount,exec,suid,relatime,dev "$ASL_CONTAINER/$container_name"
                        if [ "$?" = "0" ]; then
                            asl_print "挂载 / 成功！"
                        else
                            asl_print "挂载 / 失败！"
                        fi
                    else
                        asl_print "/ 已挂载，本次跳过！"
                    fi
                    ;;
                "/proc")
                    if ! is_mounted "$ASL_CONTAINER/$container_name/proc"; then
                        [ -d "$ASL_CONTAINER/$container_name/proc" ] || mkdir -p "$ASL_CONTAINER/$container_name/proc"
                        mount -t proc proc "$ASL_CONTAINER/$container_name/proc"
                        if [ "$?" = "0" ]; then
                            asl_print "挂载 /proc 成功！"
                        else
                            asl_print "挂载 /proc 失败！"
                        fi
                    else
                        asl_print "/proc 已挂载，本次跳过！"
                    fi
                    ;;
                "/sys")
                    if ! is_mounted "$ASL_CONTAINER/$container_name/sys"; then
                        [ -d "$ASL_CONTAINER/$container_name/sys" ] || mkdir -p "$ASL_CONTAINER/$container_name/sys"
                        mount -t sysfs sys "$ASL_CONTAINER/$container_name/sys"
                        if [ "$?" = "0" ]; then
                            asl_print "挂载 /sys 成功！"
                        else
                            asl_print "挂载 /sys 失败！"
                        fi
                    else
                        asl_print "/sys 已挂载，本次跳过！"
                    fi
                    ;;
                "/dev")
                    if ! is_mounted "$ASL_CONTAINER/$container_name/dev"; then
                        [ -d "$ASL_CONTAINER/$container_name/dev" ] || mkdir -p "$ASL_CONTAINER/$container_name/dev"
                        mount -o bind /dev "$ASL_CONTAINER/$container_name/dev"
                        if [ "$?" = "0" ]; then
                            asl_print "挂载 /dev 成功！"
                        else
                            asl_print "挂载 /dev 失败！"
                        fi
                    else
                        asl_print "/dev 已挂载，本次跳过！"
                    fi
                    ;;
                "/dev/shm")
                    if ! is_mounted "/dev/shm"; then
                        [ -d "/dev/shm" ] || mkdir -p "/dev/shm"
                        mount -o rw,nosuid,nodev,mode=1777 -t tmpfs tmpfs /dev/shm
                    fi
                    if ! is_mounted "$ASL_CONTAINER/$container_name/dev/shm"; then
                        [ -d "$ASL_CONTAINER/$container_name/dev/shm" ] || mkdir -p "$ASL_CONTAINER/$container_name/dev/shm"
                        mount -o bind /dev/shm "$ASL_CONTAINER/$container_name/dev/shm"
                        if [ "$?" = "0" ]; then
                            asl_print "挂载 /dev/shm 成功！"
                        else
                            asl_print "挂载 /dev/shm 失败！"
                        fi
                    else
                        asl_print "/dev/shm 已挂载，本次跳过！"
                    fi
                    ;;
                "/dev/pts")
                    if ! is_mounted "/dev/pts"; then
                        [ -d "/dev/pts" ] || mkdir -p "/dev/pts"
                        mount -o rw,nosuid,noexec,gid=5,mode=620,ptmxmode=000 -t devpts devpts /dev/pts
                    fi
                    if ! is_mounted "$ASL_CONTAINER/$container_name/dev/pts"; then
                        [ -d "$ASL_CONTAINER/$container_name/dev/pts" ] || mkdir -p "$ASL_CONTAINER/$container_name/dev/pts"
                        mount -o bind /dev/pts "$ASL_CONTAINER/$container_name/dev/pts"
                        if [ "$?" = "0" ]; then
                            asl_print "挂载 /dev/pts 成功！"
                        else
                            asl_print "挂载 /dev/pts 失败！"
                        fi
                    else
                         asl_print "/proc 已挂载，本次跳过！"
                    fi
                    ;;
                "/dev/fd")
                    if [ ! -e "/dev/fd" -o ! -e "/dev/stdin" -o ! -e "/dev/stdout" -o ! -e "/dev/stderr" ]; then
                        [ -e "/dev/fd" ] || ln -s /proc/self/fd /dev/
                        [ -e "/dev/stdin" ] || ln -s /proc/self/fd/0 /dev/stdin
                        [ -e "/dev/stdout" ] || ln -s /proc/self/fd/1 /dev/stdout
                        [ -e "/dev/stderr" ] || ln -s /proc/self/fd/2 /dev/stderr
                    fi
                    ;;
               "/dev/tty")
                    if [ ! -e "/dev/tty0" ]; then
                        ln -s /dev/null /dev/tty0
                    fi
                    ;;
               "/dev/net/tun")
                    if [ ! -e "/dev/net/tun" ]; then
                        [ -d "/dev/net" ] || mkdir -p /dev/net
                        mknod /dev/net/tun c 10 200
                    fi
                    ;;
               "/proc/sys/fs/binfmt_misc")
                    if [ -d "/proc/sys/fs/binfmt_misc" ]; then
                        if ! is_mounted "/proc/sys/fs/binfmt_misc"; then
                            mount -t binfmt_misc binfmt_misc "/proc/sys/fs/binfmt_misc"
                        fi
                    fi
                    ;;
               "/sdcard")
                    if ! is_mounted "$ASL_CONTAINER/$container_name/mnt/sdcard"; then
                        [ -d "$ASL_CONTAINER/$container_name/mnt/sdcard" ] || mkdir -p "$ASL_CONTAINER/$container_name/mnt/sdcard"
                        mount --bind -o rw,lazytime,nosuid,nodev,noexec,noatime,user_id=0,group_id=0,allow_other /storage/emulated/0 "$ASL_CONTAINER/$container_name/mnt/sdcard"
                        if [ "$?" = "0" ]; then
                            asl_print "挂载 /sdcard 成功！"
                        else
                            asl_print "挂载 /sdcard 失败！"
                        fi
                    else
                        asl_print "/sdcard 已挂载，本次跳过！"
                    fi
                    ;;
            esac
        done
        sed -i 's/CONTAINER_MOUNT_STATUS=[^>]*/CONTAINER_MOUNT_STATUS=yes/' $ASL_STATUS/${container_name}_status
        sed -i "s/SYSTEM_UPTIME=[^>]*/SYSTEM_UPTIME=$(date -d "$(uptime -s)" +%s)/" $ASL_STATUS/${container_name}_status
    fi
}

function umount_partitions() {
    local container_name="$1"
    local partition
    if [ ! -f "$ASL_STATUS/${container_name}_status" ]; then
        echo "CONTAINER_MOUNT_STATUS=yes" >$ASL_STATUS/${container_name}_status
        echo "SYSTEM_UPTIME=$(date -d "$(uptime -s)" +%s)" >>$ASL_STATUS/${container_name}_status
    fi
    local mount_status=$(grep 'CONTAINER_MOUNT_STATUS' $ASL_STATUS/${container_name}_status | cut -d '=' -f 2)
    local system_uptime=$(grep 'SYSTEM_UPTIME' $ASL_STATUS/${container_name}_status | cut -d '=' -f 2)
    local absolute_value=$(expr $system_uptime - $(date -d "$(uptime -s)" +%s))
    if [ "${absolute_value#-}" -gt "2" ] || [ "$mount_status" != "no" ]; then
        for partition in $ASL_PARTITIONS; do
            case "$partition" in
                "/")
                    umount -lf "$ASL_CONTAINER/$container_name" >/dev/null 2>&1
                    if [ "$?" = "0" ]; then
                        asl_print "取消挂载 / 成功！"
                    else
                        asl_print "取消挂载 / 失败！"
                    fi
                    ;;
                "/proc")
                    umount -lf "$ASL_CONTAINER/$container_name/proc" >/dev/null 2>&1
                    if [ "$?" = "0" ]; then
                        asl_print "取消挂载 /proc 成功！"
                    else
                        asl_print "取消挂载 /proc 失败！"
                    fi
                    ;;
                "/sys")
                    umount -lf "$ASL_CONTAINER/$container_name/sys" >/dev/null 2>&1
                    if [ "$?" = "0" ]; then
                        asl_print "取消挂载 /sys 成功！"
                    else
                        asl_print "取消挂载 /sys 失败！"
                    fi
                    ;;
                "/dev")
                    umount -lf "$ASL_CONTAINER/$container_name/dev" >/dev/null 2>&1
                    if [ "$?" = "0" ]; then
                        asl_print "取消挂载 /dev 成功！"
                    else
                        asl_print "取消挂载 /dev 失败！"
                    fi
                    ;;
                "/dev/shm")
                    umount -lf "$ASL_CONTAINER/$container_name/dev/shm" >/dev/null 2>&1
                    umount -lf /dev/shm >/dev/null 2>&1
                    if [ "$?" = "0" ]; then
                        asl_print "取消挂载 /dev/shm 成功！"
                    else
                        asl_print "取消挂载 /dev/shm 失败！"
                    fi
                    ;;
                "/dev/pts")
                    umount -lf "$ASL_CONTAINER/$container_name/dev/pts" >/dev/null 2>&1
                    umount -lf /dev/pts >/dev/null 2>&1
                    if [ "$?" = "0" ]; then
                        asl_print "取消挂载 /dev/pts 成功！"
                    else
                        asl_print "取消挂载 /dev/pts 失败！"
                    fi
                    ;;
                "/proc/sys/fs/binfmt_misc")
                    if [ -d "/proc/sys/fs/binfmt_misc" ]; then
                        umount -lf "/proc/sys/fs/binfmt_misc" >/dev/null 2>&1
                        if [ "$?" = "0" ]; then
                            asl_print "取消挂载 /dev/pts 成功！"
                        else
                            asl_print "取消挂载 /dev/pts 失败！"
                        fi
                    fi
                    ;;
                "/sdcard")
                    umount -lf "$ASL_CONTAINER/$container_name/mnt/sdcard" >/dev/null 2>&1
                    if [ "$?" = "0" ]; then
                        asl_print "取消挂载 /sdcard 成功！"
                    else
                        asl_print "取消挂载 /sdcard 失败！"
                    fi
                    ;;
            esac
        done
        sed -i 's/CONTAINER_MOUNT_STATUS=[^>]*/CONTAINER_MOUNT_STATUS=no/' $ASL_STATUS/${container_name}_status
        sed -i "s/SYSTEM_UPTIME=[^>]*/SYSTEM_UPTIME=$(date -d "$(uptime -s)" +%s)/" $ASL_STATUS/${container_name}_status
    fi
}

function close_container() {
    local container_name="$1"
    asl_print "正在扫描 $container_name 容器进程..."
    local lsof_full=$(lsof | awk '{print $1}' | grep -c '^lsof')
    if [ "$lsof_full" -eq "0" ]; then
        local pids=$(lsof | grep "$ASL_CONTAINER/$container_name" | awk '{print $1}' | uniq)
    else
        local pids=$(lsof | grep "$ASL_CONTAINER/$container_name" | awk '{print $2}' | uniq)
    fi
    asl_print "正在停止进程..."
    if [ -n "$pids" ]; then
        for pid in $pids; do
            kill -9 "$pid"
        done
    fi
    asl_print "正在取消挂载分区..."
    umount_partitions "$container_name"
    asl_print "关闭 $container_name 容器成功！..."
}

function temporarily_container_exec() {
    local container_name="$1"
    shift
    if [ "$ASL_MODE" = "unshare" ]; then
        mount_partitions "$container_name"
        unset TMP TEMP TMPDIR LD_PRELOAD LD_DEBUG
        [ -n "${TERM}" ] || TERM="linux"
        [ -n "${PS1}" ] || PS1="\u@\h:\w\\$ "
        mkdir -p "$ASL_CONTAINER/$container_name/root"
        if [ "$#" -gt "0" ]; then
            $UNSHARE -R "$ASL_CONTAINER/$container_name" -w /root /usr/bin/env -i HOME=/root USER=root PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games TERM=$TERM LANG=zh_CN.UTF-8 /bin/su - root -c "$*"
        else
            $UNSHARE -R "$ASL_CONTAINER/$container_name" -w /root /usr/bin/env -i HOME=/root USER=root PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games TERM=$TERM LANG=zh_CN.UTF-8 /bin/su - root
        fi
    elif [ "$ASL_MODE" = "proot" ]; then
        unset TMP TEMP TMPDIR LD_PRELOAD LD_DEBUG
        [ -n "${TERM}" ] || TERM="linux"
        [ -n "${PS1}" ] || PS1="\u@\h:\w\\$ "
        mkdir -p "$ASL_CONTAINER/$container_name/root"
        if [ "$#" -gt "0" ]; then
            $PROOT --link2symlink -0 -r "$ASL_CONTAINER/$container_name" -b /dev -b /proc -b /sys -b /sdcard:/mnt/sdcard -b $ASL_CONTAINER/$container_name/root:/dev/shm -w /root /usr/bin/env -i HOME=/root USER=root PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games TERM=$TERM LANG=zh_CN.UTF-8 /bin/su - root -c "$*"
        else
            $PROOT --link2symlink -0 -r "$ASL_CONTAINER/$container_name" -b /dev -b /proc -b /sys -b /sdcard:/mnt/sdcard -b $ASL_CONTAINER/$container_name/root:/dev/shm -w /root /usr/bin/env -i HOME=/root USER=root PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games TERM=$TERM LANG=zh_CN.UTF-8 /bin/su - root
        fi
    else
        asl_print "未配置好ASL_MODE，请检查asl.conf！"
    fi
}

function container_exec() {
    local container_name="$1"
    shift
    if [ "$ASL_MODE" = "unshare" ]; then
        mount_partitions "$container_name"
        unset TMP TEMP TMPDIR LD_PRELOAD LD_DEBUG
        [ -n "${TERM}" ] || TERM="linux"
        [ -n "${PS1}" ] || PS1="\u@\h:\w\\$ "
        if [ "$CREATE_USER" = "true" ]; then
            if [ "$#" -gt "0" ]; then
                $UNSHARE -R "$ASL_CONTAINER/$container_name" -w /home/$USER_NAME /usr/bin/env -i HOME=/home/$USER_NAME USER=$USER_NAME PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games TERM=$TERM LANG=zh_CN.UTF-8 SHELL=/bin/bash /bin/su - $USER_NAME -c "$*"
            else
                $UNSHARE -R "$ASL_CONTAINER/$container_name" -w /home/$USER_NAME /usr/bin/env -i HOME=/home/$USER_NAME USER=$USER_NAME PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games TERM=$TERM LANG=zh_CN.UTF-8 SHELL=/bin/bash /bin/su - $USER_NAME
            fi
        elif [ "$CREATE_USER" = "false" ]; then
            if [ "$#" -gt "0" ]; then
                $UNSHARE -R "$ASL_CONTAINER/$container_name" -w /root /usr/bin/env -i HOME=/root USER=root PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games TERM=$TERM LANG=zh_CN.UTF-8 /bin/su - root -c "$*"
            else
                $UNSHARE -R "$ASL_CONTAINER/$container_name" -w /root /usr/bin/env -i HOME=/root USER=root PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games TERM=$TERM LANG=zh_CN.UTF-8 /bin/su - root
            fi
        else
            asl_print "未配置好CREATE_USER，请检查asl.conf！"
        fi
    elif [ "$ASL_MODE" = "proot" ]; then
        unset TMP TEMP TMPDIR LD_PRELOAD LD_DEBUG
        [ -n "${TERM}" ] || TERM="linux"
        [ -n "${PS1}" ] || PS1="\u@\h:\w\\$ "
        if [ "$CREATE_USER" = "true" ]; then
            if [ "$#" -gt "0" ]; then
                $PROOT --link2symlink -0 -r "$ASL_CONTAINER/$container_name" -b /dev -b /proc -b /sys -b /sdcard:/mnt/sdcard -b $ASL_CONTAINER/$container_name/root:/dev/shm -w /home/$USER_NAME /usr/bin/env -i HOME=/home/$USER_NAME USER=$USER_NAME PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games TERM=$TERM LANG=zh_CN.UTF-8 /bin/su - $USER_NAME -c "$*"
            else
                $PROOT --link2symlink -0 -r "$ASL_CONTAINER/$container_name" -b /dev -b /proc -b /sys -b /sdcard:/mnt/sdcard -b $ASL_CONTAINER/$container_name/root:/dev/shm -w /home/$USER_NAME /usr/bin/env -i HOME=/home/$USER_NAME USER=$USER_NAME PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games TERM=$TERM LANG=zh_CN.UTF-8 /bin/su - $USER_NAME
            fi
        elif [ "$CREATE_USER" = "false" ]; then
            if [ "$#" -gt "0" ]; then
                $PROOT --link2symlink -0 -r "$ASL_CONTAINER/$container_name" -b /dev -b /proc -b /sys -b /sdcard:/mnt/sdcard -b $ASL_CONTAINER/$container_name/root:/dev/shm -w /root /usr/bin/env -i HOME=/root USER=root PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games TERM=$TERM LANG=zh_CN.UTF-8 /bin/su - root -c "$*"
            else
                $PROOT --link2symlink -0 -r "$ASL_CONTAINER/$container_name" -b /dev -b /proc -b /sys -b /sdcard:/mnt/sdcard -b $ASL_CONTAINER/$container_name/root:/dev/shm -w /root /usr/bin/env -i HOME=/root USER=root PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games TERM=$TERM LANG=zh_CN.UTF-8 /bin/su - root
            fi
        else
            asl_print "未配置好CREATE_USER，请检查asl.conf！"
        fi
    else
        asl_print "未配置好ASL_MODE，请检查asl.conf！"
    fi
}
