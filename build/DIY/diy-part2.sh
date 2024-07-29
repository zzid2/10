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


print_yellow "正在执行diy-part2.sh脚本......"
# 修改默认IP为192.168.10.1
sed -i 's/192.168.1.1/10.10.10.1/g' package/base-files/files/bin/config_generate 

# 修改 root密码登录为空（免密码登录）
sed -i 's@.*CYXluq4wUazHjmCDBCqXF*@#&@g' package/lean/default-settings/files/zzz-default-settings

# ttyd 自动登录
sed -i "s?/bin/login?/usr/libexec/login.sh?g" package/feeds/packages/ttyd/files/ttyd.config

# 修改主机名（不能纯数字或者中文）
# sed -i 's/OpenWrt/G-DOCK/g' package/base-files/files/bin/config_generate                                                                    ## 把初始默认的“OpenWrt” 修改为：G-DOCK
# sed -i '/uci commit system/i\uci set system.@system[0].hostname='OpenWrtx86'' package/lean/default-settings/files/zzz-default-settings      ## 再初始默认基础上修改为：OpenWrtx86

# 修改固件版本号 添加代码：LEDE build $(TZ=UTC-8 date "+%Y.%m.%d") 显示范例：LEDE build 2021.02.08 @ OpenWrt        说明：【LEDE=作者 + build=建造 + （UTC-8=字符编码 + date=时间格式）】
sed -i "s/OpenWrt /LEDE build $(TZ=UTC-8 date "+%Y.%m.%d") @ OpenWrt /g" package/lean/default-settings/files/zzz-default-settings

# 修改 默认主题
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
#sed -i '/set luci.main.mediaurlbase=\/luci-static\/bootstrap/d' feeds/luci/themes/luci-theme-bootstrap/root/etc/uci-defaults/30_luci-theme-bootstrap   # 命令的结果是删除代码：set luci.main.mediaurlbase=/luci-static/bootstrap
# sed -i 's/ +luci-theme-bootstrap//g' feeds/luci/collections/luci/Makefile                                                                             # 取掉默认主题


# echo '修改时区'
sed -i "s/'UTC'/'CST-8'\n\t\tset system.@system[-1].zonename='Asia\/Shanghai'/g" package/base-files/files/bin/config_generate                 ## 把 UTC 时区改为：CST-8  并换行添加：set system.@system[-1].zonename='Asia/Shanghai'（ \t\tset = 用于对齐新插入的行）

# 修改输出固件名称（参考：Lede-20240726-openwrt）
# sed -i 's/IMG_PREFIX:=$(VERSION_DIST_SANITIZED)/IMG_PREFIX:=Lede-$(shell date +%Y-%m-%d)-$(VERSION_DIST_SANITIZED)/g' include/image.mk

# 添加自定义软件包
# echo '
# CONFIG_PACKAGE_luci-app-mosdns=y
# CONFIG_PACKAGE_luci-app-adguardhome=y
# CONFIG_PACKAGE_luci-app-openclash=y
# ' >> .config

# 修改内核版本
#sed -i 's/KERNEL_PATCHVER:=4.14/KERNEL_PATCHVER:=4.19/g' target/linux/x86/Makefile




# git clone https://github.com/openwrt-xiaomi/luci-app-cpufreq package/otherapp/luci-app-cpufreq              # CPU性能调节（适用arm处理器）
# sed -i 's/LUCI_DEPENDS.*/LUCI_DEPENDS:=\@\(arm\|\|aarch64\)/g' package/lean/luci-app-cpufreq/Makefile
# sed -i 's/services/system/g' package/lean/luci-app-cpufreq/luasrc/controller/cpufreq.lua                    # 把默认 services 修改为：system




# 添加温度显示(By YYiiEt)   # 在703行  or "1"%>   后面添加代码；
# sed -i 's/or "1"%>/or "1"%> ( <%=luci.sys.exec("expr `cat \/sys\/class\/thermal\/thermal_zone0\/temp` \/ 1000") or "?"%> \&#8451; ) /g' feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm



# 主题
# https://github.com/garypang13/luci-theme-edge        # Edge 带背景音乐


# ----------------------无效的代码------------------------
# 修改版本号
# sed -i 's/V2020/V$(date "+%Y.%m.%d")/g' package/lean/default-settings/files/zzz-default-settings                  # 修改版本号 将文件中所有的 V2020 替换为当前日期，格式为 YYYY.MM.DD。
# sed -i 's/V2020/V2024/g' package/base-files/files/etc/banner



# ----------------------我是分界线------------------------
# --------------------以下是非必须部分--------------------






# 修改插件名字（修改名字后不知道会不会对插件功能有影响，自己多测试）
sed -i 's/"管理权"/"改密码"/g' feeds/luci/modules/luci-base/po/zh-cn/base.po

sed -i 's/"KMS 服务器"/"KMS激活"/g' feeds/luci/applications/luci-app-vlmcsd/po/zh-cn/vlmcsd.po
# sed -i 's/"Turbo ACC 网络加速"/"Turbo ACC 网络加速"/g' feeds/luci/applications/luci-app-turboacc/po/zh-cn/turboacc.po   # 把默认 Turbo ACC 网络加速  修改为：网络加速
# sed -i 's/cbi("qbittorrent"), _("qBittorrent"), 20/cbi("qbittorrent"), _("BT下载"), 20/g' package/otherapp/luci-app-qbittorrent/luasrc/controller/qbittorrent.lua    # 把第二个 qbittorrent   修改为：BT下载



# 修改插件名字（修改名字后不知道会不会对插件功能有影响，自己多测试）
# sed -i 's/"BaiduPCS Web"/"百度网盘"/g' package/lean/luci-app-baidupcs-web/luasrc/controller/baidupcs-web.lua
# sed -i 's/cbi("qbittorrent"),_("qBittorrent")/cbi("qbittorrent"),_("BT下载")/g' package/lean/luci-app-qbittorrent/luasrc/controller/qbittorrent.lua
# sed -i 's/"aMule设置"/"电驴下载"/g' package/lean/luci-app-amule/po/zh-cn/amule.po
# sed -i 's/"网络存储"/"存储"/g' package/lean/luci-app-amule/po/zh-cn/amule.po
# sed -i 's/"网络存储"/"存储"/g' package/lean/luci-app-vsftpd/po/zh-cn/vsftpd.po
# sed -i 's/"Turbo ACC 网络加速"/"网络加速"/g' package/lean/luci-app-flowoffload/po/zh-cn/flowoffload.po
# sed -i 's/"Turbo ACC 网络加速"/"网络加速"/g' package/lean/luci-app-sfe/po/zh-cn/sfe.po
# sed -i 's/"实时流量监测"/"流量"/g' package/lean/luci-app-wrtbwmon/po/zh-cn/wrtbwmon.po
# sed -i 's/"KMS 服务器"/"KMS激活"/g' package/lean/luci-app-vlmcsd/po/zh-cn/vlmcsd.zh-cn.po
# sed -i 's/"USB 打印服务器"/"打印服务"/g' package/lean/luci-app-usb-printer/po/zh-cn/usb-printer.po
# sed -i 's/"网络存储"/"存储"/g' package/lean/luci-app-usb-printer/po/zh-cn/usb-printer.po
# sed -i 's/TTYD 终端/命令窗/g' feeds/luci/transplant/luci-app-ttyd/po/zh-cn/terminal.po
# sed -i 's/"Web 管理"/"Web管理"/g' package/lean/luci-app-webadmin/po/zh-cn/webadmin.po
# sed -i 's/"管理权"/"改密码"/g' feeds/luci/modules/luci-base/po/zh-cn/base.po
# sed -i 's/"带宽监控"/"监视"/g' feeds/luci/applications/luci-app-nlbwmon/po/zh-cn/nlbwmon.po


