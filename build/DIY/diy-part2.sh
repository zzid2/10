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

# ttyd （自动登录）
sed -i "s?/bin/login?/usr/libexec/login.sh?g" package/feeds/packages/ttyd/files/ttyd.config

# 修改主机名（不能纯数字或者中文）在机型脚本中修改，这里不修改。
# sed -i 's/OpenWrt/G-DOCK/g' package/base-files/files/bin/config_generate                                                                     ## 初始默认的“OpenWrt” 修改为：G-DOCK
sed -i '/uci commit system/i\uci set system.@system[0].hostname='OpenWrt_x86'' package/lean/default-settings/files/zzz-default-settings      ## 生成默认的基础上添加为：OpenWrtx86（推荐修改）

# 修改固件版本号 添加代码：LEDE build $(TZ=UTC-8 date "+%Y.%m.%d") 显示范例：LEDE build 2021.02.08 @ OpenWrt        说明：【LEDE=作者 + build=建造 + （UTC-8=字符编码 + date=时间格式）】
sed -i "s/OpenWrt /LEDE build $(TZ=UTC-8 date "+%Y.%m.%d") @ OpenWrt /g" package/lean/default-settings/files/zzz-default-settings

# 修改 默认主题（添加luci-theme-argon主题时，会自动设置为默认）
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
#sed -i '/set luci.main.mediaurlbase=\/luci-static\/bootstrap/d' feeds/luci/themes/luci-theme-bootstrap/root/etc/uci-defaults/30_luci-theme-bootstrap   # 命令的结果是删除代码：set luci.main.mediaurlbase=/luci-static/bootstrap
# sed -i 's/ +luci-theme-bootstrap//g' feeds/luci/collections/luci/Makefile                                                                             # 取掉默认主题

# 更改 Argon 主题背景
# cp -f $lede_path/build/DIY/img/bg1.jpg package/otherapp/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg

# echo '修改时区'
# sed -i "s/'UTC'/'CST-8'\n\t\tset system.@system[-1].zonename='Asia\/Shanghai'/g" package/base-files/files/bin/config_generate                           ## 把 UTC 时区改为：CST-8  并换行添加：set system.@system[-1].zonename='Asia/Shanghai'（ \t\tset = 用于对齐新插入的行）

# 修改内核版本
# grep 'KERNEL_PATCHVER:=' target/linux/x86/Makefile                                                            ## 查看当前内核版本
# sed -i 's/KERNEL_PATCHVER:=.*/KERNEL_PATCHVER:=5.15/g' target/linux/x86/Makefile                              ## 修改5.15=内核版本

# 修改输出固件名称（案例：Lede-20240726-openwrt）
# sed -i 's/IMG_PREFIX:=$(VERSION_DIST_SANITIZED)/IMG_PREFIX:=Lede-$(shell date +%Y-%m-%d)-$(VERSION_DIST_SANITIZED)/g' include/image.mk




# 添加自定义软件包（Luci插件）
# echo '
# CONFIG_PACKAGE_luci-app-mosdns=y
# CONFIG_PACKAGE_luci-app-adguardhome=y
# CONFIG_PACKAGE_luci-app-openclash=y
# ' >> .config


# 取消Samba36  选择Samba4
# sed -i '/CONFIG_PACKAGE_autosamba=y/d' .config                    ## 取消勾选 autosamba
# sed -i '/CONFIG_PACKAGE_luci-app-samba=y/d' .config               ## 取消勾选 luci-app-samba
# sed -i '/CONFIG_PACKAGE_samba36-server=y/d' .config               ## 取消勾选 samba36-server
# echo "CONFIG_PACKAGE_luci-app-samba4=y" >> .config                ## 勾选 luci-app-samba4
# echo "CONFIG_PACKAGE_samba4=y" >> .config                         ## 勾选 samba4

# sed -i '/CONFIG_TARGET_IMAGES_CONSOLE=y/d' .config                ## 取消开机跑代码


# ----------------------我是分界线，以下是非必须部分--------------------------------------------------------------------------------------------
# feeds/luci/modules/luci-mod-admin-full/luasrc/controller/admin/index.lua                                      # 编辑 左侧菜单选项源文件（不推荐）
# feeds/luci/modules/luci-base/po/zh-cn/base.po                                                                 # 添加 多语言翻译（推荐修改 base.po 文件）

# 修改 base.po 翻译文件（菜单选项）
sed -i 's/"管理权"/"改密码"/g' feeds/luci/modules/luci-base/po/zh-cn/base.po                                    ## 修改 管理权=改密码
sed -i '/msgid "VPN"/{n;s/.*/msgstr "虚拟网络"/;b};$!b;$a\ \nmsgid "VPN"\nmsgstr "虚拟网络"' feeds/luci/modules/luci-base/po/zh-cn/base.po              ## 先查找替换，如果没有就添加， VPN=虚拟网络



# 添加 base.po 翻译文件 （菜单选项）  （搜索"base.po"文件内容,如果内容中没有时 添加翻译文件；）
# sed -i '/msgid "VPN"/{n;s/.*/msgstr "虚拟网络"/}' feeds/luci/modules/luci-base/po/zh-cn/base.po               ## 修改 VPN=虚拟专用网络
# echo -e '\nmsgid "VPN"\nmsgstr "虚拟网络"' >> feeds/luci/modules/luci-base/po/zh-cn/base.po                   ## 添加 VPN=虚拟网络


# 修改已有插件名
sed -i 's/"Web 管理"/"Web管理"/g' feeds/luci/applications/luci-app-webadmin/po/zh-cn/webadmin.po
# sed -i 's/TTYD 终端/命令窗/g' feeds/luci/applications/luci-app-ttyd/po/zh-cn/terminal.po
# sed -i 's/"Turbo ACC 网络加速"/"Turbo ACC 网络加速"/g' feeds/luci/applications/luci-app-turboacc/po/zh-cn/turboacc.po                                 # 把默认 Turbo ACC 网络加速  修改为：网络加速
sed -i 's/"KMS 服务器"/"KMS激活"/g' feeds/luci/applications/luci-app-vlmcsd/po/zh-cn/vlmcsd.po



# 移动插件菜单项 （菜单选项）
# sed -i 's/"vpn"/"nas"/g' feeds/luci/applications/luci-app-zerotier/luasrc/controller/zerotier.lua                                                       # 移动 “luci-app-zerotier” 从 vpn 移动至 nas 菜单中； （确保关联的 luasrc/controller/admin/index.lua 文件中存在）；
# sed -i 's/"vpn"/"nas"/g' /usr/lib/lua/luci/controller/zerotier.lua && /etc/init.d/uhttpd restart                                                      # 在路由器上直接修改
# sed -i 's/{"admin", "vpn"/{"admin", "nas"/g' feeds/luci/applications/luci-app-zerotier/luasrc/controller/zerotier.lua                                 # 只修改路径，其他不修改，不推荐！！













# sed -i 's/cbi("qbittorrent"), _("qBittorrent"), 20/cbi("qbittorrent"), _("BT下载"), 20/g' package/otherapp/luci-app-qbittorrent/luasrc/controller/qbittorrent.lua    # 把第二个 qbittorrent   修改为：BT下载
# sed -i 's/"BaiduPCS Web"/"百度网盘"/g' package/lean/luci-app-baidupcs-web/luasrc/controller/baidupcs-web.lua
# sed -i 's/cbi("qbittorrent"),_("qBittorrent")/cbi("qbittorrent"),_("BT下载")/g' package/lean/luci-app-qbittorrent/luasrc/controller/qbittorrent.lua
# sed -i 's/"aMule设置"/"电驴下载"/g' package/lean/luci-app-amule/po/zh-cn/amule.po
# sed -i 's/"网络存储"/"存储"/g' package/lean/luci-app-amule/po/zh-cn/amule.po
# sed -i 's/"网络存储"/"存储"/g' package/lean/luci-app-vsftpd/po/zh-cn/vsftpd.po
# sed -i 's/"实时流量监测"/"流量"/g' package/lean/luci-app-wrtbwmon/po/zh-cn/wrtbwmon.po
# sed -i 's/"USB 打印服务器"/"打印服务"/g' package/lean/luci-app-usb-printer/po/zh-cn/usb-printer.po
# sed -i 's/"网络存储"/"存储"/g' package/lean/luci-app-usb-printer/po/zh-cn/usb-printer.po
# sed -i 's/"带宽监控"/"监视"/g' feeds/luci/applications/luci-app-nlbwmon/po/zh-cn/nlbwmon.po



# ----------------------无效的代码--------------------------------------------------------------------------------------------------------------

# 添加温度显示（在703行  or "1"%>   后面添加代码）无效果
# sed -i 's/or "1"%>/or "1"%> ( <%=luci.sys.exec("expr `cat \/sys\/class\/thermal\/thermal_zone0\/temp` \/ 1000") or "?"%> \&#8451; ) /g' feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm


# git clone https://github.com/openwrt-xiaomi/luci-app-cpufreq package/otherapp/luci-app-cpufreq              # CPU性能调节（适用arm处理器）
# sed -i 's/LUCI_DEPENDS.*/LUCI_DEPENDS:=\@\(arm\|\|aarch64\)/g' package/lean/luci-app-cpufreq/Makefile
# sed -i 's/services/system/g' package/lean/luci-app-cpufreq/luasrc/controller/cpufreq.lua                    # 把默认 services 修改为：system


# x86 型号只显示 CPU 型号
#sed -i 's/${g}.*/${a}${b}${c}${d}${e}${f}${hydrid}/g' package/lean/autocore/files/x86/autocore


# 修改本地时间格式
#sed -i 's/os.date()/os.date("%a %Y-%m-%d %H:%M:%S")/g' package/lean/autocore/files/*/index.htm


#避免出现下面的警告 提前将mosdns_neo 改为mosdns （2022.08.13目前新版源码貌似已修复此警告）
#sed -i 's/mosdns.*neo/mosdns/g' feeds/kenzo/luci-app-mosdns/Makefile


# 修改版本号
# sed -i 's/V2020/V$(date "+%Y.%m.%d")/g' package/lean/default-settings/files/zzz-default-settings                  # 修改版本号 将文件中所有的 V2020 替换为当前日期，格式为 YYYY.MM.DD。
# sed -i 's/V2020/V2024/g' package/base-files/files/etc/banner


