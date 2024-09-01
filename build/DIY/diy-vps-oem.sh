#!/bin/bash
lede_path=$(pwd)                         ## 赋于成变量= 当前执行目录，lede源码目录；
cd $lede_path                            ## 进入（Lede目录）内并执行操作；


# 字体颜色配置
print_error() {                           ## 打印红色字体
    echo -e "\033[31m$1\033[0m"
}

print_green() {                           ## 打印绿色字体
    echo -e "\033[32m$1\033[0m"
}

print_yellow() {                          ## 打印黄色字体
    echo -e "\033[33m$1\033[0m"
}


print_yellow "正在执行diy-vps-oem.sh脚本......"

sed -i '/CONFIG_PACKAGE_luci-app-samba4=y/d' .config                ## 编译菜单取消 luci-app-samba4配置
sed -i 's/CONFIG_PACKAGE_luci-app-samba4=y/CONFIG_PACKAGE_luci-app-samba4=n/' .config


echo "CONFIG_PACKAGE_luci-app-samba4=n" >> .config            # 设置为不编译