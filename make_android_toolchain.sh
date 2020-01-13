#########################################################################
# File Name: make_android_toolchain.sh
# Author: liuwch
# mail: liuwenchang1234@163.com
# Created Time: 五  6/21 10:15:11 2019
#########################################################################
#!/bin/bash

# NDK目录 r17c是最后一个支持 gcc 的 ndk
export NDK_HOME=~/android-ndk-r20

# 生成交叉编译链工具
toolchain=${NDK_HOME}/build/tools/make-standalone-toolchain.sh

# 生成交叉编译链保存在当前目录子文件夹android-toolchain
install_root=~/android-toolchain-r20-llvm

# 生成32位库最低支持到android4.3，64位库最低支持到android5.0,
# 最新版的ffmpeg，x264需要最低 android-23 就是 android 6.0 因为cabs()等函数。
apis=(
	"23"
	"23"
	"23"
	"23"
	"23"
)

# 支持以下5种cpu框架
archs=(
	"arm"
	"arm"
	"arm64"
	"x86"
	"x86_64"
)

# cpu 型号
abis=(
	"armeabi"
	"armeabi-v7a"
	"arm64-v8a"
	"x86"
	"x86_64"
)

hosts=(
  "arm-linux-androideabi"
  "arm-linux-androideabi"
  "aarch64-linux-android"
  "x86-linux-android"
  "x86_64-linux-android"
)

echo "$NDK_HOME"
echo "安装在目录 $install_root"

# --deprecated-headers

num=${#archs[@]}
for ((i=0; i < num; i++))
do
	echo "正在安装 ${archs[i]} ..."
	$toolchain --arch=${archs[i]} --platform=android-${apis[i]} --toolchain=${hosts[i]}-clang5.0 --install-dir=$install_root/${abis[i]} --use-llvm --stl=libc++
done
