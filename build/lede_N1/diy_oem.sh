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


print_yellow "正在执行diy-oem.sh脚本......"
# 修改主机名（不能纯数字或者中文）
file="package/lean/default-settings/files/zzz-default-settings"      ## 文件的路径
hostname_line="uci set system.@system[0].hostname='N1'"              ## 插入的内容（默认OpenWrtx86=替换为主机名）
if grep -q "uci set system.@system\[0\].hostname=" "$file"; then
    print_green "注意：已存在主机名，替换为新名称"
    sed -i "s|uci set system.@system\[0\].hostname=.*|$hostname_line|" "$file"
else
    print_green "注意：不存在主机名，插入新名称"
    sed -i "/uci commit system/i\\$hostname_line" "$file"
fi
# 修改wifi名称
sed -i 's/OpenWrt/N1/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh


# 修复核心及添加温度显示
# sed -i 's|pcdata(boardinfo.system or "?")|luci.sys.exec("uname -m") or "?"|g' feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm
# sed -i 's/or "1"%>/or "1"%> ( <%=luci.sys.exec("expr `cat \/sys\/class\/thermal\/thermal_zone0\/temp` \/ 1000") or "?"%> \&#8451; ) /g' feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm

# 增加带WiFi驱动，emmc写入和NTFS格式优盘挂载

# packages=" \
# brcmfmac-firmware-43430-sdio brcmfmac-firmware-43455-sdio kmod-brcmfmac wpad acl attr kmod-usb-hid kmod-mmc-spi \
# kmod-sdhci dumpe2fs e2freefrag f2fs-tools fuse-utils lsattr mkhfs nfs-utils nfs-utils-libs squashfs-tools-mksquashfs \
# squashfs-tools-unsquashfs swap-utils bash kmod-fs-ext4 kmod-fs-vfat kmod-fs-exfat dosfstools e2fsprogs ntfs-3g-utils \
# badblocks usbutils kmod-usb-ohci-pci kmod-usb-uhci kmod-usb2-pci kmod-usb3 kmod-usb-storage-extras kmod-usb-storage-uas \
# kmod-usb-net kmod-usb-net-asix-ax88179 kmod-usb-net-rtl8150 kmod-usb-net-rtl8152 autocore-arm \
# blkid lsblk parted fdisk cfdisk losetup tar gawk getopt perl perlbase-utf8 resize2fs tune2fs pv unzip \
# lscpu htop iperf3 curl lm-sensors install-program
# "
# sed -i '/FEATURES+=/ { s/cpiogz //; s/ext4 //; s/ramdisk //; s/squashfs //; }' \
    # target/linux/armvirt/Makefile
# for x in $packages; do
    # sed -i "/DEFAULT_PACKAGES/ s/$/ $x/" target/linux/armvirt/Makefile
# done


# rm -f package/lean/shadowsocksr-libev/patches/0002-Revert-verify_simple-and-auth_simple.patch
# sed -i '383,393 d' package/lean/shadowsocksr-libev/patches/0001-Add-ss-server-and-ss-check.patch
# sed -i 's/PKG_RELEASE:=5/PKG_RELEASE:=6/' package/lean/shadowsocksr-libev/Makefile
# sed -i '/PKG_SOURCE_VERSION:=/d' package/lean/shadowsocksr-libev/Makefile
# sed -i '/PKG_SOURCE_URL/a PKG_SOURCE_VERSION:=4799b312b8244ec067b8ae9ba4b85c877858976c' \
    # package/lean/shadowsocksr-libev/Makefile
