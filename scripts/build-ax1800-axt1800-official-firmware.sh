#!/bin/bash

profile=$2

ui=$3

if [ ! -n "$profile" ]; then
	profile=target_wlan_ap-gl-ax1800
fi

if [ ! -n "$ui" ]; then
        ui=true
fi

echo "当前目录"
pwd

echo "当前目录内容"
ls -alh

git clone https://github.com/gl-inet/gl-infra-builder.git /workdir/gl-infra-builder

echo "进入目标目录"
cd /home/runner/work/build-gl.inet/build-gl.inet/

echo "复制自定义插件源码至官方的插件目录"
cp -r custom/  /workdir/gl-infra-builder/feeds/custom/

echo "添加passwall"
git clone -b packages https://github.com/qqhpc/xiaorouji-openwrt-passwall.git /workdir/gl-infra-builder/feeds/custom/passwall
git clone -b luci https://github.com/qqhpc/xiaorouji-openwrt-passwall.git /workdir/gl-infra-builder/feeds/custom/luci-app-passwall
cp -r /workdir/gl-infra-builder/feeds/custom/luci-app-passwall/luci-app-passwall /workdir/gl-infra-builder/feeds/custom/passwall/
rm -rf /workdir/gl-infra-builder/feeds/custom/luci-app-passwall

echo "添加passwall2"
git clone https://github.com/qqhpc/xiaorouji-openwrt-passwall2.git /workdir/gl-infra-builder/feeds/custom/passwall2
cp -r /workdir/gl-infra-builder/feeds/custom/passwall2/luci-app-passwall2 /workdir/gl-infra-builder/feeds/custom/ && rm -rf /workdir/gl-infra-builder/feeds/custom/passwall2

echo "添加luci-app-adguardhome"
git clone https://github.com/qqhpc/rufengsuixing-luci-app-adguardhome.git /workdir/gl-infra-builder/feeds/custom/luci-app-adguardhome

echo "复制插件自定义配置文件至官方的配置目录"
cp -r *.yml /workdir/gl-infra-builder/profiles/

cd /workdir/gl-infra-builder

echo "选择内核版本并下载对应源码"
if [[ $profile == *5-4* ]]; then
        python3 setup.py -c configs/config-wlan-ap-5.4.yml
else
        python3 setup.py -c configs/config-wlan-ap.yml
fi

echo "进入openwrt目录"
cd wlan-ap/openwrt

echo "更新插件源码"
./scripts/gen_config.py $profile glinet_depends custom

echo "克隆glinet私有软件包"
git clone https://github.com/gl-inet/glinet4.x.git /workdir/gl-infra-builder/glinet

echo "下载feeds"
./scripts/feeds update -a

echo "更新Golang"
rm -rf feeds/packages/lang/golang
svn co https://github.com/openwrt/packages/branches/openwrt-22.03/lang/golang feeds/packages/lang/golang

echo "安装feeds packages"
./scripts/feeds install -a

echo "安装feeds packages again"
./scripts/feeds install -a -f

echo "生成配置文件"
make defconfig

echo ""
if [[ $ui == true  ]]; then 
	make -j$(expr $(nproc) + 1) GL_PKGDIR=/workdir/gl-infra-builder/glinet/ipq60xx/ V=s
else
	make -j$(expr $(nproc) + 1)  V=s
fi
