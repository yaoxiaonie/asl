<div align="center">

# Android Subsystem for Linux
这是一个适用于Android设备的Linux容器工具，同时也是让Linux容器开机自启动ssh的KernelSU/Magisk模块

![last commit](https://img.shields.io/github/last-commit/yaoxiaonie/asl)
![stars](https://img.shields.io/github/stars/yaoxiaonie/asl)
![license](https://img.shields.io/github/license/yaoxiaonie/asl)

</div>

## 支持情况
- [x] Ubuntu
- [x] Debian
- [ ] ArchLinux（正在适配）

## 已知问题
- ArchLinux目前pacman换源后遇到堵塞，目前没有时间去解决，如果有大佬能解决欢迎pr

## 待实现功能
- [x] 代码重构
- [ ] 使用Go语言重构项目
- [ ] 对自启动列表的管理
- [ ] 多容器管理及启动
- [ ] 自定义挂载点
- [ ] run-parts和sysv初始化
- [ ] 一键部署VNC（解决声音，黑屏）

## 使用方法
- 在KernelSU/Magisk中安装本模块
- 用终端管理器使用ASL命令安装Linux容器
- 使用asl -m <容器名称>来设置需要启动的容器
- 重启手机后即可享用

## 使用示例
- 安装ubuntu的impish版本

> asl -i 'ubuntu,impish,<容器名称>'

- 安装最新版的ArchLinux

> asl -i 'archlinux,current,<容器名称>'

- 登录Linux容器

> asl -l <容器名称>

- 关闭Linux容器

> asl -c <容器名称>

- 删除Linux容器

> asl -d <容器名称>

- 设置Linux容器自启动（仍在完善，移除自启动请到/data/asl/auto-startup.txt里）

> asl -m <容器名称>

- 快捷启动Linux容器ssh

> asl -s <容器名称>

- 在Linux容器内部执行命令

> asl -e <容器名称> <命令>

## 第三方开源引用
- GNU General Public License V3

  [meefik/linuxdeploy-cli](https://github.com/meefik/linuxdeploy-cli)

- Apache License 2.0

  [2moe/tmoe](https://github.com/2moe/tmoe)

## License
[GNU General Public License v3.0](https://github.com/yaoxiaonie/asl/blob/master/LICENSE)
