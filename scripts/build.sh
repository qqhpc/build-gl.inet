#!/bin/bash

profile=$2

ui=$3

if [ ! -n "$profile" ]; then
	profile=target_wlan_ap-gl-ax1800
fi

if [ ! -n "$ui" ]; then
        ui=true
fi

cd /home/runner/work/build-gl.inet/build-gl.inet/

echo "复制自定义插件源码目录至官方的插件目录"
cp -r custom/  /workdir/gl-infra-builder/feeds/custom/

echo "复制插件自定义配置文件官方的配置目录"
cp -r *.yml /workdir/gl-infra-builder/profiles

cd /workdir/gl-infra-builder

echo "选择内核版本并下载对应源码"
if [[ $profile == *5-4* ]]; then
        python3 setup.py -c configs/config-wlan-ap-5.4.yml
else
        python3 setup.py -c configs/config-wlan-ap.yml
fi

echo "进入目标目录"
cd wlan-ap/openwrt

echo "更新插件源码"
./scripts/gen_config.py $profile glinet_depends custom

echo "克隆glinet私有软件包"
git clone https://github.com/qqhpc/glinet4.x.git /workdir/gl-infra-builder/glinet

echo "下载安装feeds"
./scripts/feeds update -a

echo "更新Golang"
rm -rf feeds/packages/lang/golang
svn co https://github.com/openwrt/packages/branches/openwrt-22.03/lang/golang/golang feeds/packages/lang/golang

echo "安装feeds packages"
./scripts/feeds install -a

echo "生成配置文件"
make defconfig

echo ""
if [[ $ui == true  ]]; then 
	make -j$(expr $(nproc) + 1) GL_PKGDIR=/workdir/gl-infra-builder/glinet/ipq60xx/ V=s
else
	make -j$(expr $(nproc) + 1)  V=s
fi

