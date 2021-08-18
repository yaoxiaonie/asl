#!/system/bin/sh

ui_print "- 解压模块中..."
unzip -o "$ZIPFILE" -x 'META-INF/*' -d $MODPATH >&2

ui_print "- 创建工作目录..."
mkdir -p /data/asl/bin
mkdir -p /data/asl/rootfs

ui_print "- 配置工作环境..."
mv $MODPATH/asl/bin/* /data/asl/bin/
ln -s /data/asl/bin/asl.sh /system/xbin/asl

ui_print "- 移除多于文件..."
rm -rf $MODPATH/customize.sh 2>/dev/null
set_perm_recursive $MODPATH 0 0 0755 0644

ui_print "- 完成！"
