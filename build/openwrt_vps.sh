#!/bin/bash

#--------------------------------------------------------------
#	系统环境: Ubuntu-20.04.4-LTS
#	一键编译: 本地VPS一键编译Openwrt
#	项目地址: https://github.com/bigbugcc/Openwrt（本地编译）
#	脚本地址：https://github.com/bigbugcc/OpenWrts（云编译）
#--------------------------------------------------------------

#--------------------------------------------------------------------------------------------
# apt-get update && apt-get upgrade -y            ## 第一步 更新_软件和系统；
# chmod +x ./diy_openwrt.sh                       ## 第二步 脚本提权限；
# ./diy_openwrt.sh                                ## 第三步 首次编译运行；
# ./make.sh                                       ## 第四步 二次编译运行（在LEDE目录内运行）
# screen -S 10                                    /在A主机上创建为“10”的会话；
# screen -r                                       /恢复刚才创建的会话

# screen -ls　　　　　　　　　　　　          　　/在B主机上查询已存在的会话
# screen -D -r ID数字                             /多个窗口恢复
#--------------------------------------------------------------------------------------------


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


# 环境变量
 project_path=$(cd `dirname $0`; pwd)                ## 当前脚本目录= （仓库目录）将当前脚本所在的目录路径 赋于成变量；
 lede_path="$project_path/lede"                      ## 赋于成变量= lede源码目录
 
 REPO_URL="https://github.com/coolsnowwolf/lede"     ## Lede源码
 REPO_BRANCH="master"                                ## master分支
 REPO_MAIN="main"                                    ## main分支
 CangKu="zzid2/100"                                  ## 作者仓库（如果更换仓库，这里需要修改）

 
# 单独下载GitHub文件夹
svn_export() {
	# 参数1是分支名, 参数2是子目录, 参数3是目标目录, 参数4仓库地址
	trap 'rm -rf "$TMP_DIR"' 0 1 2 3
	TMP_DIR="$(mktemp -d)" || exit 1
	[ -d "$3" ] || mkdir -p "$3"
	TGT_DIR="$(cd "$3"; pwd)"
	cd "$TMP_DIR" && \
	git init >/dev/null 2>&1 && \
	git remote add -f origin "$4" >/dev/null 2>&1 && \
	git checkout "remotes/origin/$1" -- "$2" && \
	cd "$2" && cp -a . "$TGT_DIR/"
}


cd $project_path                                                                ## 切换到仓库项目的主目录内


# 安装编译环境（变量文件env）
print_yellow "***安装编译环境"
echo "qq963" | sudo -S apt-get update && apt-get upgrade -y                     ## 更新_软件和系统 免密码执行；
sudo -E apt-get -qq install -y curl git lrzsz progress screen                   ## 安装基础软件

sudo rm -rf /etc/apt/sources.list.d/* /usr/share/dotnet /usr/local/lib/android /opt/ghc                                                       ## 删除：sources.list.d 目录、dotnet 目录、android目录、ghc目录。
sudo -E apt-get -qq update -y && sudo -E apt-get -qq upgrade -y && sudo -E apt-get -qq autoremove -y --purge && sudo -E apt-get -qq clean     ## 更新软件包引、安装软件包、删除无用软件包、清理 APT 缓存。

if [ -f "DIY/env" ];then   # 如果本地不存在，就在线下载；
	print_green "***使用本地环境文件env***"
else
	print_yellow "***下载环境文件env***"
	mkdir -p DIY                     # 新建DIY目录；
	curl -Ls https://raw.githubusercontent.com/$CangKu/$REPO_MAIN/build/DIY/env -o DIY/env      ## 下载环境文件env
fi
sudo apt-get -y install $(awk '{print $1}' DIY/env)                             ## 安装环境文件env（自动去除"注释"信息）

sudo -E apt-get -qq install -y xz-utils btrfs-progs zip dosfstools uuid-runtime pigz             ## N1固件打包必需要的依赖


# 下载Lean源码
if [ -d "$lede_path" ]; then         # 如果本地不存在，就在线下载
    print_green " ***退出脚本：请执行“make.sh”进行二次编译！！！*** "
    exit 0           # 正常退出
else
    print_yellow "***下载Lean大源码***"
    git clone --depth 1 $REPO_URL $lede_path
    if [ $? -eq 0 ]; then
        print_green "***lede源码下载完成***"
    else
        print_error "***lede源码下载失败***"
        exit 1      # 异常退出
    fi
fi


cd $lede_path                                                                     ## 进入Lede源码目录内并执行操作


# 加载diy-part1.sh脚本；
if [ -f "$project_path/DIY/diy-part1.sh" ];then   # 如果本地不存在，就在线下载；
	print_green "***使用本地diy-part1.sh***"
else
	print_yellow "***下载diy-part1.sh***"
	curl -L https://raw.githubusercontent.com/$CangKu/$REPO_MAIN/build/DIY/diy-part1.sh -o $project_path/DIY/diy-part1.sh		## 下载diy-part1.sh
fi
cp -rf $project_path/DIY/diy-part1.sh $lede_path/diy-part1.sh     ## 复制到Lede源码目录内
bash $lede_path/diy-part1.sh                                      ## Lede源码目录内执行
rm -rf $lede_path/diy-part1.sh


# 加载diy-part2.sh脚本；
if [ -f "$project_path/DIY/diy-part2.sh" ]; then   # 如果本地不存在，就在线下载；
	print_green "***使用本地diy-part2.sh***"
else
	print_yellow "***下载diy-part2.sh***"
	curl -L https://raw.githubusercontent.com/$CangKu/$REPO_MAIN/build/DIY/diy-part2.sh -o $project_path/DIY/diy-part2.sh		## 下载diy-part2.sh
fi
cp -rf $project_path/DIY/diy-part2.sh $lede_path/diy-part2.sh     ## 复制到Lede源码目录内
bash $lede_path/diy-part2.sh                                      ## Lede源码目录内执行
rm -rf $lede_path/diy-part2.sh
## 修改默认IP为10.10.10.1


# 加载机型配置configs目录；
if [ -d "$project_path/DIY/configs" ];then         # 如果本地不存在，就在线下载；
	print_green "***使用本地configs机型目录***"
else
	print_yellow "***下载configs***"
	svn_export "main" "build/DIY/configs" "$project_path/DIY/configs" https://github.com/$CangKu                                ## 下载configs        ## 参数1= 分支名, 参数2= 仓库子目录, 参数3= 本地目标目录, 参数4= 仓库地址。
fi
cp -rv $project_path/DIY/configs $lede_path/configs


# 复制本地.config文件；
if [ -f "$project_path/DIY/.config" ]; then       ## 如果本地不存在，就在线下载；
	print_green "***使用本地.config配置***"
else 
	print_yellow "***下载.config***"
	curl -L https://raw.githubusercontent.com/$CangKu/$REPO_MAIN/build/DIY/.config -o $project_path/DIY/.config                 ## 下载.config
fi
rm -f $lede_path/.config                            ## 先删除源码内默认的.config插件配置文件；
cp -fv $project_path/DIY/.config $lede_path         ## 复制本地 DIY/.config插件配置文件至lede目录下；

cd $project_path                                                                    ## 进入仓库项目的主目录内


# 开始执行make.sh编译脚本；
if [ -f "$project_path/DIY/make.sh" ];then          ## 如果本地存在，直接执行编译；不存在就下载脚本。
	chmod +x DIY/make.sh
	cp DIY/make.sh $lede_path
    $lede_path/make.sh
else
		curl -L https://raw.githubusercontent.com/$CangKu/$REPO_MAIN/build/DIY/make.sh -o DIY/make.sh                           ## 下载make.sh编译脚本
		cp DIY/make.sh $lede_path
		
        if [ -f "$lede_path/make.sh" ];then 
                print_green "搜索到make.sh文件，正在执行！"
				chmod +x $lede_path/make.sh
                $lede_path/make.sh 
		else
                print_error "错误！不存在make.sh文件，将不会自动编译固件" 
    	fi
fi




