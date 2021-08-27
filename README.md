<h1 align="center">ASL</h1>

<p align="center">
	Android subsystem for Linux（安卓子系统）
</p>

## 安装支持
目前只支持基于debian发行版的Linux安装，arch系Linux待支持...

## 如何安装asl？
### 1. 从本仓库的[Release](https://github.com/yaoxiaonie/asl/releases)中下载最新的版本
### 2. 用Magisk Manager安装从[Release](https://github.com/yaoxiaonie/asl/releases)下载的模块

## 如何使用asl安装rootfs容器？
### 1. 打开任意终端软件
### 2. 获取root权限
> su

### 3. 安装ubuntu的impish版本（或是别的Linux）
> asl -i ubuntu impish

### 4. 至此结束，请等待从清华源获取完毕，或指定rootfs的路径安装
> asl -i ubuntu ubuntu.tar.xz

## 更多帮助
> asl -h or asl --help
