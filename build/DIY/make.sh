#!/bin/bash

# 环境变量
 lede_path=$(cd `dirname $0`; pwd)         ## 当前脚本目录= （Lede目录）将当前脚本所在的目录路径 赋于成变量；
 cd $lede_path                             ## 进入（Lede目录）内并执行操作；
 date=$(date "+%Y.%m.%d-%H%M")
 date1=$(date "+%Y年%m月%d号-%H点%M分")

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


# 更新源码
function updatesource {
 print_yellow "====== 更新源码以及组件 ======"
 git pull

 ./scripts/feeds update -a
 ./scripts/feeds install -a


# 更新App插件（package/otherapp目录内的插件）
 folder="$lede_path/package/otherapp"                       ## 目录变量=Openwrt-main/package/otherapp目录
 softfiles=$(ls $folder)                                    ## 目录变量=列出otherapp目录列表

# 更新appsname目录下的插件
 print_yellow "========== 开始检查更新app源码 =========="
 for sfile in ${softfiles}
 do 
	echo "${sfile}:"
	cd $folder/${sfile} && git pull                         ## 进入lede/package/otherapp目录内 并更新插件
done
cd $lede_path                                               ## 进入Lede源码目录内并执行操作
}



#---------------------------------------------------------------------------------------------------------------------------------------
function x86_64 {             ## x86_64
 cat configs/x86_64.config > .config && makes
}


function x86_64Lite {         ## x86_64精简版，单独执行命令！
 cat configs/x86_64Lite.config > .config
 cat configs/LuciApp_Lite.config >> .config
 make defconfig
 down_dl             ## 下载DL库压缩包（外网用不到！）
 print_yellow "CPU线程数：$(($(nproc)+1))   进行全线程编译..."
 make -j$(($(nproc)+1)) V=s || make -j1 V=s            ## 如果报错，用单线程编译排错：make -j1 V=s
 weixin              ## 微信通知
 break
}


function Raspberry4 {        ## 树莓派 4
 cat configs/RPi4.config > .config && makes
}


function Raspberry3 {        ## 树莓派 3
 cat configs/RPi3B.config > .config && makes
}


function Rockchip {          ## 友善ARM__系列
 cat configs/Rockchip.config > .config && makes
}


function N1_pack {           ## N1固件打包
# cat configs/N1.config > .config && makes                    ## 先加载 N1.config 机型配置，然后开始编译固件；
 pack                ## N1打包脚本命令
}


function compileUp {         ## 使用当前.config配置进行编译，单独执行命令！
 make defconfig
 down_dl                     ## 下载DL库压缩包（外网用不到！）
 print_yellow "CPU线程数：$(($(nproc)+1))   进行全线程编译..."
 make -j$(($(nproc)+1)) V=s || make -j1 V=s            ## 如果报错，用单线程编译排错：make -j1 V=s
 weixin              ## 微信通知
 break
}
#---------------------------------------------------------------------------------------------------------------------------------------



function openMenu {          ## 打开Make编译菜单
 make defconfig && make menuconfig
 break
}


function cleanCache {        ## 清除编译缓存
 make clean && make dirclean
}


function makes {             ## 通用配置（自定义插件）
 cat configs/LuciApp.config >> .config && make defconfig
 down_dl             ## 下载DL库压缩包（外网用不到！）
 print_yellow "CPU线程数：$(($(nproc)+1))   进行全线程编译..."
 make -j$(($(nproc)+1)) V=s || make -j1 V=s            ## 首选全速线程编译，如果报错 再进行单线程编译排查错误！
 weixin              ## 微信通知
 break
}


function down_dl {           ## 下载DL库压缩包（外网用不到！）
 cd ../
if [ -d "$lede_path/dl" ]; then      ## 判断 Lede 目录内是否有“DL文件夹”， 如果没有 就“执行下载判断”
	print_yellow "***DL库目录已经存在***"                                                          ## lede/dl 文件如果存在，提示跳过；
else
	if [ -f "./dl.tar.gz" ];then   ## 判断 当前是否有 dl.tar.gz 压缩包， 如果没有 就联网下载到当前目录内（下载判断）；
		print_green "***复制本地 dl.tar.gz 压缩包***"
		cp dl.tar.gz $lede_path                                                                    ## 复制当前 dl.tar.gz 压缩包至Lede目录内；
		tar -zxvf $lede_path/dl.tar.gz -C $lede_path/ && rm -f $lede_path/dl.tar.gz                ## 先解压 dl.tar.gz 压缩包，然后再删除压缩包；
	else
		print_green "***下载 dl.tar.gz 压缩包***"
		wget -P $lede_path http://10.10.10.16:21704/api/public/dl/GhWWQ_HT/dl.tar.gz               ## 联通下载 dl.tar.gz 压缩包至Lede目录内；   ## 在链接后缀加/dl.tar.gz
		tar -zxvf $lede_path/dl.tar.gz -C $lede_path/ && rm -f $lede_path/dl.tar.gz                ## 先解压 dl.tar.gz 压缩包，然后再删除压缩包；
	fi
fi

 cd $lede_path

 make -j$(($(nproc)+1)) download V=s      ## 全线程下载DL库
# find dl -size -1024c -exec ls -l {} \;  ## 检查小于1KB文件
# find dl -size -1024c -exec rm -f {} \;  ## 删除小于1KB文件
 make -j1 download V=s                    ## 再次执行单线程下载DL库


# tar -czvf dl.tar.gz dl                ## 打包当前DL文件夹为压缩包命令；

}


function pack {
 cd ../                       ## 退回至上级项目仓库主目录

if [ ! -d "./N1opt" ];then
	if [ ! -f "./N1opt.tar.gz" ];then
		print_green "***下载 N1packaging 源码***"
		# wget http://10.10.10.16:21704/api/public/dl/160KJMDr/N1opt.tar.gz && tar -zxvf N1opt.tar.gz && rm -f N1opt.tar.gz                         ## 局域网下载
		git clone --depth 1 https://github.com/wxfyes/N1packaging N1opt                            ## 外网下载
	else
		print_green "***解压本地 N1packaging 源码***"
		tar -zxvf N1opt.tar.gz && rm -f N1opt.tar.gz
	fi
else
	print_yellow "***N1packaging源码目录已存在***"
fi
	
	## N1打包“70+0核心”（推荐70+o稳定版）
	# echo qq963 | sudo -S （后面输入执行命令）                                                      ## shell脚本内sudo无需输入密码      echo "password" | sudo -S sh -c "cat hosts.patch >> /etc/hosts"
	
	echo "qq963" | sudo -S chmod  -R 777 /opt                                                        ## 免输入密码，提权777 /opt 目录
	find N1opt/70+o/opt/* -name "*kernel*" | xargs -i cp -r {} /opt                                  ## 搜索 70+o目录内的“kernel”文件夹 并复制到 根目录下的/opt目录内
	cp lede/bin/targets/*/*/*rootfs.tar.gz /opt/kernel/openwrt-armvirt-64-default-rootfs.tar.gz      ## 复制 N1输出固件至根目录下的/opt/kernel目录内 并重命名为 openwrt-armvirt-64-default-rootfs.tar.gz
	cd /opt/kernel                                                                                   ## 进入 /opt/kernel 工作目录内，准备开始打包固件。
	sudo chmod  -R 777 /opt                                                                          ## 再次提权777 /opt 目录，用于操作目录内的其他文件
	sudo chmod +x *.sh                                                                               ## 当前 /opt/kernel 目录内，所有脚本提权限至 可执行文件！
	sudo ./mk_s905d_n1.sh                                                                            ## 开始N1打包脚本命令！！！ 打包后默认名称为：N1-wangxiaofeng-70+o.img
	sudo chmod -R 777 tmp                                                                            ## tmp目录提权777
	mv tmp/N1-*-70+o.img tmp/N1-lede-70+o.img                                                        ## 输出固件重命名为：N1-lede-70+o.img
	sudo cp files/update-amlogic-openwrt.sh tmp/update-amlogic-openwrt.sh                            ## 复制更新脚本至 tmp 目录内，
	cd tmp                                                                                           ## 进入tmp目录
	sudo pigz -9 N1-*-70+o.img                                                                       ## 压缩N1固件，
	mv -f *.img.gz -t $lede_path/bin/targets/*/*                                                     ## 移动固件至     原armvirt固件输出目录内
	mv -f *.sh -t $lede_path/bin/targets/*/*                                                         ## 移动更新脚本至 原armvirt固件输出目录内
	rm -rf /opt/kernel                                                                               ## 删除根目录下的/opt/kernel目录文件
	
	cd $lede_path                                    ## 进入Lede源码目录内并执行操作
	cd ../
	
	## N1打包“70+核心”测试版（和70+o打包命令一致）
	echo "qq963" | sudo -S chmod  -R 777 /opt
	find N1opt/70+/opt/* -name "*kernel*" | xargs -i cp -r {} /opt
	cp lede/bin/targets/*/*/*rootfs.tar.gz /opt/kernel/openwrt-armvirt-64-default-rootfs.tar.gz
	cd /opt/kernel
	sudo chmod  -R 777 /opt
	sudo chmod +x *.sh
	sudo ./mk_s905d_n1.sh
	sudo chmod -R 777 tmp
	mv tmp/N1-*-70+.img tmp/N1-lede-70+.img
	sudo cp files/update-amlogic-openwrt.sh tmp/update-amlogic-openwrt.sh
	cd tmp
	sudo pigz -9 N1-*-70+.img
	mv -f *.img.gz -t $lede_path/bin/targets/*/*
	mv -f *.sh -t $lede_path/bin/targets/*/*
	rm -rf /opt/kernel
	
	cd $lede_path                                    ## 进入Lede源码目录内并执行操作
	
}


##微信通知
function weixin {


local IFS="";
str_sucess="{\"token\":\"d9d4ff882fb9473e87b3ee605d936293\",\"title\":\"openWrt编译成功！\",\"content\":\"编译固件已完成！编译时间：$date1\",\"template\":\"html\"}"
str_err="{\"token\":\"d9d4ff882fb9473e87b3ee605d936293\",\"title\":\"固件编译出错！\",\"content\":\"编译未完成，快去排查报错问题！编译时间：$date1\",\"template\":\"html\"}"
echo "file = $lede_path/bin/targets";

if find $lede_path/bin/targets/ -name "*img.gz" | read ;then
	curl --location --request POST 'https://www.pushplus.plus/send' --header 'User-Agent: Apifox/1.0.0 (https://apifox.com)' --header 'Content-Type: application/json' --data $str_sucess
else
	curl --location --request POST 'https://www.pushplus.plus/send' --header 'User-Agent: Apifox/1.0.0 (https://apifox.com)' --header 'Content-Type: application/json' --data $str_err
fi
}






function menu {
 clear
 echo
 echo -e "
                                           _.oo.
                   _.u[[/;:,.         .odMMMMMM'
                .o888UU[[[/;:-.  .o@P^    MMM^
               oN88888UU[[[/;::-.        dP^  
              dNMMNN888UU[[[/;:--.   .o@P^         
            ,MMMMMMN888UU[[/;::-. o@^         
             NNM[ BigBugcc ][/.o@P^        ___              __      _____ _____         
             888888888UU[[[/o@^-..        / _ \ _ __  ___ _ \ \    / / _ \_   _|                                 
            oI8888UU[[[/o@P^:--..        | (_) | '_ \/ -_) ' \ \/\/ /|   / | |
         .@^  YUU[[[/o@^;::---..          \___/| .__/\___|_||_\_/\_/ |_|_\ |_|  
       oMP     ^/o@P^;:::---..                 |_|                              
    .dMMM    .o@^ ^;::---...                                                     
   dMMMMMMM@^`       `^^^^                                         
  YMMMUP^                 
   ^^ ------------------------ https://github.com/bigbugcc -----------------------------
    "
 echo -e "\t\t Openwrt 编译菜单\n"                # 首页菜单提示
 
 echo -e "\t1. x86_64"                    # x86_64
 echo -e "\t2. x86_64 精简版"             # x86_64Lite
 echo -e "\t3. 树莓派_Pi4"                # Raspberry4
 echo -e "\t4. 树莓派_Pi3B+"              # Raspberry3
 echo -e "\t5. 友善ARM__系列(R4S、R2S、OPiR1Plus) "  # Rockchip
 echo -e "\t6. 使用当前_.config配置编译"  # compileUp
 echo -e "\t7. 打开编译_配置菜单"         # openMenu
 echo -e "\t8. 清除编译缓存"              # cleanCache
 echo -e "\t9. N1_镜像打包"           # N1_pack
 echo -e "\t0. 退出菜单\n\n"
 
 echo -en "\t\t输入一个选项: "
 read -t 300 option                          # 3000秒后自动选择（新增_判断自动）
}


updatesource                                  # 更新源码

while [ 1 ]                                   # 循环菜单
do
 menu


# echo "option = $option";                  # 显示输入的信息
 if [ -z "$option" ]; then                  # 添加的判断（新增_判断自动）
	option=6                                # 超时后自动选择第6项（新增_判断自动）
 fi                                         # 添加的判断（新增_判断自动）
 
 
 case $option in
 0)
 break ;;
 
 1)
 x86_64 ;;
 
 2)
 x86_64Lite ;;
 
 3)
 Raspberry4 ;;
 
 4)
 Raspberry3 ;;
 
 5)
 Rockchip ;;
 
 6)
 compileUp ;;
 
 7)
 openMenu ;;
 
 8)
 cleanCache ;;
 
 9)
 N1_pack;;
 
 *)
 
 clear
 echo "抱歉，选择错误" ;;
 esac
# countdown 10           # 函数倒计时10秒
 echo -en "\n\n\t\t\t 按任意键继续"
 read -n 1 line
done
clear
