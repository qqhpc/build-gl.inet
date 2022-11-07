#!/bin/bash

pwd

cd /home/runner/work/build-gl.inet/build-gl.inet/

echo "复制自定义插件源码目录至官方的插件目录"
cp -r custom/  /workdir/gl-infra-builder/feeds/custom/

echo "复制插件自定义配置文件官方的配置目录"
cp -r *.yml /workdir/gl-infra-builder/profiles

cd /workdir/gl-infra-builder

echo "下载4.x对应源码"
python3 setup.py -c ./configs/config-wlan-ap.yml

echo "进入openwrt目录"
cd ./wlan-ap/openwrt

echo "更新插件源码"
./scripts/gen_config.py target_wlan_ap-gl-axt1800 glinet_depends custom

echo "克隆glinet私有软件包"
git clone https://github.com/qqhpc/gl-inet-glinet4.x.git /workdir/gl-infra-builder/glinet

echo "下载feeds"
./scripts/feeds update -a

echo "更新Golang"
rm -rf ./feeds/packages/lang/golang
svn co https://github.com/openwrt/packages/branches/openwrt-22.03/lang/golang ./feeds/packages/lang/golang

echo "安装feeds packages"
./scripts/feeds install -a

echo "安装feeds packages again"
./scripts/feeds install -a -f

echo "生成配置文件"
make defconfig

echo "下载 dl"
make download -j2

echo "编译固件"
make -j$(expr $(nproc) + 1) GL_PKGDIR=/workdir/gl-infra-builder/glinet/ipq60xx/ V=s
