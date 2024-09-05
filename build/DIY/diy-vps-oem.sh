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


#   取消 默认编译插件
echo "CONFIG_PACKAGE_autosamba=n" >> .config                        ## 取消   Extra packages ---> autosamba
echo "CONFIG_PACKAGE_luci-app-samba4=n" >> .config                  ## 取消   luci-app-samba4

# sed -i '/CONFIG_PACKAGE_autosamba=y/d' .config                      ## 删除 autosamba
# sed -i '/CONFIG_PACKAGE_luci-app-samba4=y/d' .config                ## 删除 luci-app-samba4


sed -i '/CONFIG_PACKAGE_luci-app-autoreboot=y/d' .config            ## 删除   计划定时重启（autopoweroff二选一）
echo "CONFIG_PACKAGE_luci-app-autoreboot=n" >> .config              ## 取消   计划定时重启（autopoweroff二选一）


sed -i '/CONFIG_PACKAGE_luci-app-filetransfer=y/d' .config
echo "CONFIG_PACKAGE_luci-app-filetransfer=n" >> .config            ## 取消   文件传输（可web安装ipk包）

sed -i '/CONFIG_PACKAGE_luci-app-ssr-plus=y/d' .config
echo "CONFIG_PACKAGE_luci-app-ssr-plus=n" >> .config                ## 取消   SSR-plus

sed -i '/CONFIG_PACKAGE_luci-app-turboacc=y/d' .config
echo "CONFIG_PACKAGE_luci-app-turboacc=n" >> .config                ## 取消   TurboACC网络加速

sed -i '/CONFIG_PACKAGE_luci-app-vlmcsd=y/d' .config
echo "CONFIG_PACKAGE_luci-app-vlmcsd=n" >> .config                  ## 取消   KMS激活服务Windows

sed -i '/CONFIG_PACKAGE_luci-app-webadmin=y/d' .config
echo "CONFIG_PACKAGE_luci-app-webadmin=n" >> .config

sed -i '/CONFIG_PACKAGE_luci-app-wol=y/d' .config
echo "CONFIG_PACKAGE_luci-app-wol=n" >> .config                     ## 取消   WOL网络唤醒

sed -i '/CONFIG_PACKAGE_luci-app-zerotier=y/d' .config
echo "CONFIG_PACKAGE_luci-app-zerotier=n" >> .config




