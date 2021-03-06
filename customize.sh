
on_install() {
    ASL="/data/asl"
    if [ -d "$ASL" ]; then
        ui_print "- 检测到已安装本模块！"
        ui_print "- 正在更新模块..."
        unzip -o "$ZIPFILE" 'asl/*' -d "/data" >&2
        chmod -R 0755 "$ASL/bin"
        rm -rf /data/adb/modules/asl/system/bin/.empty
        rm -rf /data/adb/modules/asl/system/xbin/.empty
    else
        ui_print "- 正在释放模块文件..."
        mkdir -p "$ASL"
        unzip -o "$ZIPFILE" 'asl/*' -d "/data" >&2
        chmod -R 0755 "$ASL/bin"
        ln -s "$ASL/bin/asl.sh" "/data/adb/modules/asl/system/bin/asl"
        ln -s "$ASL/bin/asl.sh" "/data/adb/modules/asl/system/xbin/asl"
        rm -rf /data/adb/modules/asl/system/bin/.empty
        rm -rf /data/adb/modules/asl/system/xbin/.empty
        touch "$ASL/rootfs.config"
    fi
}

set_permissions() {
    set_perm_recursive  $MODPATH  0  0  0755  0644
}

on_install
set_permissions
