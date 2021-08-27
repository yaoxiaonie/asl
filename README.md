## 关于ASL
### Android subsystem for Linux（安卓子系统）
目前只支持基于debian发行版的Linux安装，arch系Linux待支持...

## 如何安装rootfs容器？
1. 打开任意终端软件
2. 获取root权限
> su
3. 安装ubuntu的impish版本（或是别的Linux）
> asl -i ubuntu impish
4. 至此结束，请等待从清华源获取完毕，或指定rootfs的路径安装
> asl -i ubuntu ubuntu.tar.xz

## 更多帮助
> asl -h or asl --help
