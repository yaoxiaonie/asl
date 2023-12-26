# 调试标记
DUBUG_FLAG=true

SKIPMOUNT=false

# 是否加载 system.prop
PROPFILE=false

# 是否执行 post-fs-data 脚本
POSTFSDATA=false

# 是否执行 service 脚本
LATESTARTSERVICE=true

REPLACE=""

# 获取模块版本
module_version=$(grep_prop version $TMPDIR/module.prop)

# 获取模块名称
module_name=$(grep_prop name $TMPDIR/module.prop)

# 获取模块id
module_id=$(grep_prop id $TMPDIR/module.prop)

# 获取模块作者
module_author=$(grep_prop author $TMPDIR/module.prop)

ASL_PROJECT_DIR="/data/asl"

# 介绍等(无需更改，脚本将会自动从module.prop中获取信息)
print_modname() {
    ui_print "-------------------------------------"
    ui_print "- $module_name "
    ui_print "- 作者: $module_author"
    ui_print "- 版本: $module_version"
    ui_print "-------------------------------------"
}

# 安装脚本
on_install() {
    ui_print "- 正在安装..."

    # 解压system文件夹至模块目录
    unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2

    # 解压asl文件夹至asl工作目录
    unzip -o "$ZIPFILE" 'asl/*' -d '/data' >&2
}

# 设置权限
set_permissions() {
    # 普通权限
    set_perm_recursive $MODPATH 0 0 0755 0644
    set_perm_recursive $MODPATH/system/bin 0 0 0755 0755
    set_perm_recursive $ASL_PROJECT_DIR/bin 0 0 0755 0755
    set_perm_recursive $ASL_PROJECT_DIR/include/deploy 0 0 0755 0755
}
