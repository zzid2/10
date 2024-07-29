#!/bin/bash
lede_path=$(pwd)                         ## 赋于成变量= 当前执行目录，lede源码目录；
cd $lede_path                            ## 进入（Lede目录）内并执行操作；

# 修改主机名（不能纯数字或者中文）
file="package/lean/default-settings/files/zzz-default-settings"      ## 文件的路径
hostname_line="uci set system.@system[0].hostname='G-DOCK'"          ## 插入的内容（默认OpenWrtx86=替换为主机名）
if grep -q "uci set system.@system\[0\].hostname=" "$file"; then
    echo "注意：已存在主机名，替换为新名称"
    sed -i "s|uci set system.@system\[0\].hostname=.*|$hostname_line|" "$file"
else
    echo "注意：不存在主机名，插入新名称"
    sed -i "/uci commit system/i\\$hostname_line" "$file"
fi

# 修改wifi名称
sed -i 's/OpenWrt/G-DOCK/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh