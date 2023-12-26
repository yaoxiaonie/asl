#!/system/bin/sh

# Copyright (C) 2021 MistyRain <1740621736@qq.com>

function usage() {
    echo "使用方法：$0 <参数1> <参数2> <参数3> <参数4>"
    echo -e "\t -i|--install：安装来自清华源的Linux容器「参数2为容器类型，参数3为容器版本代号」"
    echo -e "\t    当参数4为 [ --local ] 时，使用本地文件安装「参数2为文件位置，参数3为自定义的容器名」"
    echo -e "\t -c|--command：在指定容器内部执行指定命令「参数2为命令，参数3为自定义的容器名」"
    echo -e "\t -l|--login：登录至指定容器内部「参数2为容器位置」"
    echo -e "\t -d|--delete：删除指定容器「参数2为容器位置」"
    echo -e "\t -v|--version：展示ASL程序版本"
}

ASL_PROJECT=$(cd `dirname $(readlink -f $0)`;cd ..;pwd)

# asl核心配置检查
if [ -f "$ASL_PROJECT/bin/asl.conf" ]; then
    cat $ASL_PROJECT/bin/asl.conf | sed '/^#/d' | sed '/^$/d' | sed 's/: /=/g' | sed 's/^/export /g' >$ASL_PROJECT/bin/asl_opinion
    source $ASL_PROJECT/bin/asl_opinion
    rm $ASL_PROJECT/bin/asl_opinion
else
    echo "找不到asl.conf，请确保本程序资源完整！"
    exit 1
fi

# deploy资源检查
if [ ! -d "$ASL_INCLUDE/deploy" ]; then
    echo "找不到deploy文件夹，请确保本程序资源完整！"
    exit 1
fi

# deploy资源检查
if [ ! -d "$ASL_TOOLKIT/busybox" ]; then
    echo "busybox工具集丢失，正在安装..."
    mkdir -p "$ASL_TOOLKIT/busybox"
    busyboxtools --install "$ASL_TOOLKIT/busybox"
    sleep 1
    echo "安装完成！"
fi

# log开关检查
if [ "$ASL_LOG_RETURE" = "true" ]; then
    source $ASL_PROJECT/bin/cli/functions.sh
elif [ "$ASL_LOG_RETURE" = "false" ]; then
    cat $ASL_PROJECT/bin/cli/functions.sh | sed '/asl_print/c\:' >$ASL_PROJECT/bin/cli/functions_tmp.sh
    source $ASL_PROJECT/bin/cli/functions_tmp.sh
    rm $ASL_PROJECT/bin/cli/functions_tmp.sh
fi

while getopts ":i:d:l:e:s:c:m:hv" opt; do
    case $opt in
        "i")
            IFS=","; ADDR=($OPTARG)
            install_rootfs_package_online ${ADDR[@]}
            for i in "${ADDR[@]}"; do
                echo "Item: $i"
            done
            ;;
        "d")
            close_container "$OPTARG"
            rm -rf "$ASL_CONTAINER/$OPTARG"
            rm -rf "$ASL_STATUS/${OPTARG}_status"
            ;;
        "l")
            container_exec "$OPTARG"
            ;;
        "e")
            container_name=$OPTARG
            shift 2
            temporarily_container_exec "$container_name" "$*"
            ;;
        "s")
            container_name=$OPTARG
            temporarily_container_exec "$container_name" "/etc/init.d/ssh restart"
            ;;
        "c")
            close_container "$OPTARG"
            ;;
        "m")
            echo "$OPTARG" >>/data/asl/auto-startup.txt
            ;;
        "h")
            usage
            ;;
        "v")
            #shift $(($OPTIND - 1))
            echo "ASL Version: $ASL_VERSION"
            echo "Author: MistyRain"
            echo "Repo Url: https://github.com/yaoxiaonie/asl"
            ;;
        \?)
            echo $opt
            ASL_PRINT "无效的选项-$OPTARG"
            exit 1
            ;;
    esac
done
