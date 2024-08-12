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


print_yellow "正在执行diy-part1.sh脚本......"
# 显示 插件源链接
echo "***源码自带_基础核心（src-git packages https://github.com/coolsnowwolf/packages   ）***"    # 基础核心
echo "***源码自带_luci插件（src-git luci https://github.com/coolsnowwolf/luci           ）***"    # luci插件（常用插件）
echo "***源码自带_路由核心（src-git routing https://github.com/coolsnowwolf/routing     ）***"    # 路由核心
echo "***源码自带_通信核心（src-git telephony https://git.openwrt.org/feed/telephony.git）***"    # 通信核心
# sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default                                            # 取消注释源-（显示插件 luci-app-ssr-plus）


# 自带不显示插件
# echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default      # 只有 luci-app-ssr-plus（sed -i "/helloworld/d" "feeds.conf.default"）
# echo 'src-git oui https://github.com/zhaojh329/oui.git' >>feeds.conf.default            # 用于为 OpenWrt 开发 Web 界面的框架
# echo 'src-git video https://github.com/openwrt/video.git' >>feeds.conf.default          # 视频包
# echo 'src-git targets https://github.com/openwrt/targets.git' >>feeds.conf.default      # 不懂
# echo 'src-git oldpackages http://git.openwrt.org/packages.git' >>feeds.conf.default     # 不懂
# echo 'src-link custom /usr/src/openwrt/custom-feed' >>feeds.conf.default                # 不懂


# 第三方插件源码
# sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default                                         # 显示源 “helloworld” 目录= luci-app-ssr-plus 插件
# sed -i '$i '"src-git helloworld https://github.com/fw876/helloworld"'' feeds.conf.default    # 添加源 “helloworld” 目录= luci-app-ssr-plus 插件

sed -i '$a src-git luciapp https://github.com/zzid2/luci-app' feeds.conf.default            # 自己整理的源       $a= 插入最后一行， $i= 插入倒数第二行
# sed -i '$a src-git kenzok8 https://github.com/kenzok8/openwrt-packages' >>feeds.conf.default # 插件源码
# sed -i '$a src-git smpackage https://github.com/kenzok8/small-package' feeds.conf.default    # 整合插件源码（追新常用！）
# echo 'src-git small https://github.com/kenzok8/small' >>feeds.conf.default				   # 保留：luci-app-bypass  luci-app-mosdns  luci-app-passwall  luci-app-passwall2  luci-app-ssr-plus（新版本：passwall  passwall 2   SSR_Plus）
# echo 'src-git kiddin9 https://github.com/kiddin9/openwrt-packages' >>feeds.conf.default	   # kiddin9 插件源码
# echo 'src-git lienol https://github.com/Lienol/openwrt-package' >>feeds.conf.default		   # 插件源码
# echo 'src-git shidahuilang https://github.com/shidahuilang/openwrt-package' >>feeds.conf.default       # 插件源码
# echo 'src-git 281677160 https://github.com/281677160/openwrt-package' >>feeds.conf.default   # 插件源码
# echo 'src-git hululu1068 https://github.com/hululu1068/OpenWRT-Code' >>feeds.conf.default    # 插件源码
# https://github.com/pppoex/openwrt-packages     # 插件源码


#---------------------------------------------------------------------------------------------------------------------------------------
./scripts/feeds clean                               ## 清除编译临时文件
./scripts/feeds update -a                           ## 更新_插件源包（更新后目录：lede源码/feeds/***）
#---------------------------------------------------------------------------------------------------------------------------------------


cd $lede_path   #---删除 LEDE源码内 luci/applications 自带插件
if [ -d "$lede_path/feeds/luci/applications" ]; then   # 如果存在，就删除以下文件
	print_error "***删除插件***   feeds/luci/applications "
	cd $lede_path/feeds/luci/applications           # 进入 LEDE源码内applications目录内；
	mkdir -p app && find . -mindepth 1 -maxdepth 1 ! -name app -exec mv {} app/ \;             # 临时创建app文件夹，移动当前全部文件到app目录内，后续会删除；
	
	PLUGINS_TO_KEEP=(
		"luci-app-samba4"       # 网络共享
		"luci-app-firewall"     # 防火墙
		"luci-app-filetransfer" # 安装 ipk 软件包（文件传输）
		"luci-app-ttyd"         # 网页终端命令行
		"luci-app-turboacc"     # TurboACC 网络加速
		"luci-app-vlmcsd"       # KMS 服务器设置
		"luci-app-webadmin"     # Web 管理页面设置
		"luci-app-wol"          # WOL 网络唤醒
		"luci-app-zerotier"     # ZeroTier 内网穿透
	)
	for plugin in "${PLUGINS_TO_KEEP[@]}"; do
		mv -f "app/$plugin" ./
	done
	
	rm -rf app

#---------------------------------------------------------------------------------------------------------------------------------------


	cd $lede_path/feeds/luci/themes      # 进入themes主题目录
	
	rm -rf luci-theme-argon              # 删除Argon主题（旧版必删）
	rm -rf luci-theme-argon-mod          # 删除Argon主题
	# rm -rf luci-theme-bootstrap
	rm -rf luci-theme-design
	rm -rf luci-theme-material
	rm -rf luci-theme-netgear
else
	print_yellow "***目录不存在*** 路径：feeds/luci/applications "
fi


cd $lede_path   #---删除 luci-app目录内插件（自己整理的源）
if [ -d "$lede_path/feeds/luciapp" ];then   # 如果存在，就删除以下文件
	print_error "***删除插件***   feeds/luciapp（自己整理的源） "
	cd feeds/luciapp                      # 进入 LEDE源码内luciapp目录内；

	rm -rf .git							  # 删除多余的git目录
else
	print_yellow "***目录不存在*** 路径：feeds/luciapp "
fi
#---------------------------------------------------------------------------------------------------------------------------------------


cd $lede_path   #---删除 kenzok8目录内插件
if [ -d "$lede_path/feeds/kenzok8" ];then  # 如果存在，就删除以下文件
	print_error "***删除插件***   feeds/kenzok8 "
	cd $lede_path/feeds/kenzok8           # 进入 LEDE源码内kenzok8目录内；
	mkdir -p app && mv -f ./* app                   # 临时创建app文件夹，移动当前全部文件到app目录内，后续会删除；
	
	# 移动保留的插件； mv -f app/插件名称 ./
#	mv -f app/luci-app-samba4 ./                    # 网络共享（必备插件）

	rm -rf app                                      # 删除临时创建的app目录；
else
	print_yellow "***目录不存在*** 路径：feeds/kenzok8 "
fi
#---------------------------------------------------------------------------------------------------------------------------------------


cd $lede_path   #---删除 smpackage目录内插件
if [ -d "$lede_path/feeds/smpackage" ];then  # 如果存在，就删除以下文件
	print_error "***删除插件***   feeds/smpackage "
	cd $lede_path/feeds/smpackage          # 进入 LEDE源码内smpackage目录内；
	mkdir -p app && mv -f ./* app                   # 临时创建app文件夹，移动当前全部文件到app目录内，后续会删除；
	
	# 移动保留的插件； mv -f app/插件名称 ./
#	mv -f app/luci-app-samba4 ./                    # 网络共享（必备插件）

	rm -rf app                                      # 删除临时创建的app目录；
else
	print_yellow "***目录不存在*** 路径：feeds/smpackage "
fi
#---------------------------------------------------------------------------------------------------------------------------------------


cd $lede_path   #---删除 small目录内插件
if [ -d "$lede_path/feeds/small" ];then  # 如果存在，就删除以下文件
	print_error "***删除插件***   feeds/small "
	cd $lede_path/feeds/small           # 进入 LEDE源码内small目录内；
	mkdir -p app && mv -f ./* app                   # 临时创建app文件夹，移动当前全部文件到app目录内，后续会删除；
	
	# 移动保留的插件； mv -f app/插件名称 ./
#	mv -f app/luci-app-samba4 ./                    # 网络共享（必备插件）

	rm -rf app                                      # 删除临时创建的app目录；
else
	print_yellow "***目录不存在*** 路径：feeds/small "
fi


#---------------------------------------------------------------------------------------------------------------------------------------
cd $lede_path
./scripts/feeds install -a                             ##安装_插件源包（安装后目录：lede源码/package/feeds/***）
#---------------------------------------------------------------------------------------------------------------------------------------


# 最新版插件和主题
rm -rf feeds/packages/lang/golang && git clone https://github.com/sbwml/packages_lang_golang -b 22.x feeds/packages/lang/golang  ## 升级 Go版本

git clone -b 18.06 https://github.com/jerrykuku/luci-app-argon-config.git package/otherapp/luci-app-argon-config                 ##Argon主题设置
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git  package/otherapp/luci-theme-argon                          ##Argon主题；匹配Lede源码
### git clone --depth 1 https://github.com/kenzok78/luci-app-argone-config.git                        # Argon主题设置
### git clone --depth 1 https://github.com/kenzok78/luci-theme-argone.git                             # Argon主题


# 编译 po2lmo（如果有po2lmo可跳过）
if [ -d "$lede_path/package/feeds/luciapp/luci-app-openclash/tools/po2lmo" ];then
	pushd package/feeds/luciapp/luci-app-openclash/tools/po2lmo      ## 推送到po2lmo目录
	make && sudo make install                                        ## 编译安装
	popd
else
	git clone https://github.com/openwrt-dev/po2lmo.git po2lmo       ## 下载po2lmo依赖
	pushd po2lmo
	make && sudo make install
	popd
	cd $lede_path
	rm -rf po2lmo                                                    ## 安装后，删除目录
fi



# 收藏的开源作者
# https://github.com/rufengsuixing?tab=repositories
# https://github.com/haiibo/openwrt-packages              ## 带中文说明
# https://github.com/bigbugcc?tab=repositories
# https://github.com/jerrykuku?tab=repositories
# https://github.com/yichya?tab=repositories
# https://github.com/xiechangan123?tab=repositories
# https://github.com/xiaorouji?tab=repositories 
# https://github.com/garypang13/openwrt-packages
# https://github.com/frainzy1477?tab=repositories
# https://github.com/combat60?tab=repositories
# git clone https://github.com/AdguardTeam/AdGuardHome.git                                                # AdGuardHome去广告全平台源码
# https://github.com/sirpdboy?tab=repositories
# https://github.com/orgs/OpenWrt-Actions/repositories


