#!/bin/bash

# 2022.09.26

pwd

ls -alh

cd /workdir/openwrt

pwd

ls

echo "添加 helloworld"
sed -i "/helloworld/d" "feeds.conf.default" && git clone https://github.com/qqhpc/fw876-helloworld.git ./package/helloworld

echo "添加 openclash"
svn export https://github.com/qqhpc/vernesong-OpenClash/branches/dev/luci-app-openclash ./package/openclash

echo "添加 luci-app-adguardhome"
git clone https://github.com/qqhpc/rufengsuixing-luci-app-adguardhome.git ./package/luciadguardhome

echo "download feeds packages"
./scripts/feeds update -a

echo "update go"
rm -rf feeds/packages/lang/golang
svn co https://github.com/openwrt/packages/branches/openwrt-22.03/lang/golang feeds/packages/lang/golang

echo "install feeds packages"
./scripts/feeds install -a

echo "install feeds packages again"
./scripts/feeds install -a

echo "get config file"
rm -rf .config
wget https://raw.githubusercontent.com/qqhpc/configfiles/main/openwrt/21.02/.config/mt1300/rooter/ROOter-gl-mt1300.config.txt
mv ROOter-gl-mt1300.config.txt .config

echo "下载 dl"
make download -j2

echo "编译固件"
./build MT1300 -b custom-MT1300

